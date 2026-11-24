#!/usr/bin/env python3
"""Converte as folhas em grade geradas por IA (images/*.jpeg, fundo magenta) nas
folhas de sprites do jogo (art/*.png, uma linha de quadros) e grava
art/sprites.json com o número de quadros e o ponto dos pés de cada uma.

Uso:
    python3 tools/build_sprites.py            # todas as folhas
    python3 tools/build_sprites.py bruxa_magia arthur_pulo   # só algumas
    python3 tools/build_sprites.py --preview  # também salva tools/_preview.png

Para cada folha (veja SHEETS):
  1. Apaga as linhas escuras da grade, inclusive as linhas extras que às vezes
     atravessam o personagem, preenchendo com as cores dos dois lados.
  2. Corta as células e apaga textos indesejados ("erase").
  3. Remove o fundo magenta e as sombras roxas no chão.
  4. Remove sujeira: pedacinhos soltos e partes de quadros vizinhos que
     encostam na borda da célula (a não ser "keep_border").
  5. Redimensiona para o personagem ficar com a mesma altura em todas as folhas
     dele (HEIGHTS), medindo os quadros de "measure" (altura * "ratio").
  6. Mantém a posição relativa dos quadros (pulos, avanços) e alinha os pés:
     a linha do chão é a dos quadros "ground" (padrão: "measure"); quadros
     perto dessa linha ficam exatamente nela.

Os sprites saem com o dobro do tamanho lógico do jogo (desenhados com escala 0.5).

Requer Pillow (python3-pil).
"""
import json
import os
import sys
from collections import deque

from PIL import Image, ImageDraw

# Altura do personagem em pé, em pixels da folha final (2x a tela lógica).
HEIGHTS = {
    "arthur": 270,
    "dorothy": 165,
    "pitbull": 165,
    "chihuahua": 125,
    "cachorro": 160,
    "bruxa": 330,
    "banco": 175,
    "gordao": 330,
    "morador": 310,
    "ifood": 300,
    "praga": 340,
    "fantasma": 230,
    "vaca": 250,
    "rato": 180,
    "barata": 380,
    "vovos": 320,
    "caranguejo": 175,
    "ermitao": 170,
    "lagosta": 190,
    "estrela": 360,
    "pais": 330,
    "arara": 170,
    "preguica": 230,
    "hipopotamo": 215,
    "sagui": 330,
    "vovo_bosque": 300,
    "coco": 80,
}

# nome: arquivo de origem, colunas x linhas, personagem e ajustes.
#   frames: quadros usados (índices na ordem da grade); padrão: todos.
#   measure: quadros "em pé" usados para medir a altura; ratio: altura deles
#            em relação ao personagem em pé (ex.: 0.85 se estão agachados).
#   ground: quadros que definem a linha do chão; snap: "tol" (padrão), "all", "none".
#   erase: retângulos (x0, y0, x1, y1) em frações da célula, para apagar textos;
#          lista geral ou dicionário {quadro: [retângulos]}.
#   width: largura dos quadros de "measure" (para HUD), em vez da altura do personagem.
#   defringe: camadas de borda rosada a apagar (franja de magenta).
#   keep_border: não remove partes encostadas na borda (efeitos grandes).
SHEETS = {
    # Arthur
    "arthur_parado": {"src": "Arthur_Parado", "grid": (3, 2), "who": "arthur", "frames": [0, 1]},
    "arthur_derrotado": {"src": "arthur_derrotado", "grid": (3, 2), "who": "arthur",
                         "measure": [5], "ratio": 0.75, "ground": [2, 3, 4, 5]},
    "arthur_andando": {"src": "Arthur_Andando", "grid": (3, 2), "who": "arthur"},
    "arthur_correndo": {"src": "Arthur_Correndo", "grid": (3, 3), "who": "arthur",
                        "frames": [0, 1, 2, 3, 4, 6, 7, 8], "ratio": 0.95},
    "arthur_pulo": {"src": "Arthur_Pulo", "grid": (3, 2), "who": "arthur",
                    "measure": [4], "ratio": 0.97, "snap": "all"},
    "arthur_ataque": {"src": "Arthur_Ataque", "grid": (3, 2), "who": "arthur",
                      "measure": [0, 2, 5], "ratio": 0.9},
    "arthur_defesa": {"src": "Arthur_Defesa", "grid": (3, 2), "who": "arthur",
                      "measure": [0, 1, 2], "ratio": 0.9},
    "arthur_comemora": {"src": "Arthur_Comemora", "grid": (3, 2), "who": "arthur",
                        "measure": [2, 5]},
    "arthur_pum": {"src": "Arthur_Pum", "grid": (3, 3), "who": "arthur", "measure": [8]},
    "arthur_espetinho": {"src": "Arthur_Espetinho", "grid": (3, 3), "who": "arthur",
                         "measure": [3, 4], "ground": [6, 7, 8], "snap": "all"},
    # Cenário
    "banco": {"src": "banco", "grid": (1, 1), "who": "banco"},
    "coco": {"src": "coco", "grid": (3, 2), "who": "coco", "measure": [0, 1, 2], "snap": "all"},
    # HUD ("width": largura em vez de altura)
    "hud_barra": {"src": "HUD_Barra", "grid": (1, 1), "width": 600, "keep_border": True, "snap": "all", "defringe": 6},
    "hud_arthur": {"src": "HUD_Arthur", "grid": (3, 2), "width": 104, "snap": "all"},
    "hud_comandos": {"src": "HUD_Comandos", "grid": (1, 1), "width": 760, "keep_border": True, "snap": "all", "defringe": 6},
    "hud_icones": {"src": "HUD_Icones", "grid": (3, 2), "width": 70, "snap": "all"},
    # Dorothy
    "dorothy_parada": {"src": "Dorothy_Parada", "grid": (3, 2), "who": "dorothy",
                       "measure": [0, 1, 2, 3, 5]},
    "dorothy_correndo": {"src": "Dorothy_Correndo", "grid": (3, 3), "who": "dorothy", "ratio": 0.85},
    "dorothy_lambida": {"src": "Dorothy_Lambida", "grid": (3, 2), "who": "dorothy",
                        "measure": [0, 2, 5], "keep_border": True, "snap": "all"},
    "dorothy_latido": {"src": "Dorothy_Latido", "grid": (3, 3), "who": "dorothy",
                       "measure": [0, 1, 8], "ratio": 0.85, "keep_border": True},
    # Pitbull
    "pitbull_parado": {"src": "Pitbull", "grid": (1, 1), "who": "pitbull"},
    "pitbull_correndo": {"src": "Pitbull_Correndo", "grid": (3, 3), "who": "pitbull", "ratio": 0.9},
    "pitbull_ataque": {"src": "Pitbull_Ataque", "grid": (3, 2), "who": "pitbull",
                       "measure": [0, 4, 5], "keep_border": True},
    "pitbull_dano": {"src": "Pitbull_Dano", "grid": (3, 2), "who": "pitbull",
                     "measure": [0], "ratio": 0.95, "snap": "all"},
    # Chihuahua
    "chihuahua_correndo": {"src": "Chihuahua_Correndo", "grid": (3, 3), "who": "chihuahua"},
    "chihuahua_ataque": {"src": "Chihuahua_Ataque", "grid": (3, 3), "who": "chihuahua",
                         "measure": [4, 6, 7],
                         "erase": {5: [(0.8, 0.12, 1.0, 0.35)], 8: [(0.72, 0.0, 1.0, 0.3)]}},
    "chihuahua_dano": {"src": "Chihuahua_Dano", "grid": (3, 3), "who": "chihuahua",
                       "measure": [0, 1], "snap": "all"},
    # Cachorro da bruxa
    "cachorro_correndo": {"src": "CachorroBruxa_Correndo", "grid": (3, 3), "who": "cachorro"},
    "cachorro_ataque": {"src": "CachorroBruxa_Ataque", "grid": (3, 3), "who": "cachorro",
                        "measure": [0, 1, 6, 7, 8], "keep_border": True},
    "cachorro_dano": {"src": "CachorroBruxa_Dano", "grid": (3, 2), "who": "cachorro",
                      "measure": [3, 4, 5],
                      "erase": {0: [(0, 0.8, 1, 1)], 1: [(0, 0.8, 1, 1)], 2: [(0, 0.8, 1, 1)],
                                3: [(0, 0, 1, 0.2)], 4: [(0, 0, 1, 0.2)], 5: [(0, 0, 1, 0.2)]}},
    "cachorro_surgindo": {"src": "CachorroBruxa_Surgindo", "grid": (3, 3), "who": "cachorro",
                          "measure": [6, 7, 8], "snap": "all"},
    # Fase 2: gordão do espetinho (3x3: andando, ataque, dano, tonto, sentado)
    "gordao_andando": {"src": "gordao", "grid": (3, 3), "who": "gordao", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "gordao_ataque": {"src": "gordao", "grid": (3, 3), "who": "gordao", "frames": [3, 4, 5], "measure": [0, 1, 2],
                      "keep_border": True},
    "gordao_dano": {"src": "gordao", "grid": (3, 3), "who": "gordao", "frames": [6, 7], "measure": [0, 1, 2],
                    "ground": [0, 1, 2, 6, 7], "snap": "all"},
    "gordao_derrota": {"src": "gordao", "grid": (3, 3), "who": "gordao", "frames": [8], "measure": [0, 1, 2],
                       "ground": [8], "snap": "all"},
    # Morador de rua com a faca
    "morador_andando": {"src": "morador", "grid": (3, 3), "who": "morador", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "morador_ataque": {"src": "morador", "grid": (3, 3), "who": "morador", "frames": [3, 4, 5], "measure": [0, 1, 2],
                       "keep_border": True},
    "morador_dano": {"src": "morador", "grid": (3, 3), "who": "morador", "frames": [6, 7], "measure": [0, 1, 2],
                     "ground": [0, 1, 2, 6, 7], "snap": "all", "keep_border": True},
    "morador_derrota": {"src": "morador", "grid": (3, 3), "who": "morador", "frames": [8], "measure": [0, 1, 2],
                        "ground": [8], "snap": "all"},
    # Motoqueiro de entregas
    "ifood_moto": {"src": "ifood", "grid": (3, 3), "who": "ifood", "frames": [0, 1, 2], "measure": [0, 1, 2],
                   "keep_border": True},
    "ifood_manobra": {"src": "ifood", "grid": (3, 3), "who": "ifood", "frames": [3, 4, 5, 6], "measure": [0, 1, 2],
                      "ground": [0, 1, 2, 4, 5], "keep_border": True, "snap": "all"},
    "ifood_caido": {"src": "ifood", "grid": (3, 3), "who": "ifood", "frames": [7, 8], "measure": [0, 1, 2],
                    "ground": [7, 8], "snap": "all"},
    # Chefe da fase 2: o Praga, com muleta e sapato plataforma
    "praga_andando": {"src": "praga", "grid": (3, 3), "who": "praga", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "praga_muleta": {"src": "praga", "grid": (3, 3), "who": "praga", "frames": [3, 4, 5], "measure": [0, 1, 2],
                     "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "praga_xinga": {"src": "praga", "grid": (3, 3), "who": "praga", "frames": [6], "measure": [0, 1, 2],
                    "ground": [6], "snap": "all"},
    "praga_dano": {"src": "praga", "grid": (3, 3), "who": "praga", "frames": [7], "measure": [0, 1, 2],
                   "ground": [7], "snap": "all"},
    "praga_derrota": {"src": "praga", "grid": (3, 3), "who": "praga", "frames": [8], "measure": [0, 1, 2],
                      "ground": [8], "snap": "all"},
    # Fase 3: fantasma da casa abandonada (flutua; susto com bafo verde)
    "fantasma_voando": {"src": "fantasma", "grid": (3, 3), "who": "fantasma", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "fantasma_susto": {"src": "fantasma", "grid": (3, 3), "who": "fantasma", "frames": [3, 4, 5], "measure": [0, 1, 2],
                       "ground": [0, 1, 2, 3, 4, 5], "snap": "all", "keep_border": True},
    "fantasma_dano": {"src": "fantasma", "grid": (3, 3), "who": "fantasma", "frames": [6, 7], "measure": [0, 1, 2],
                      "ground": [0, 1, 2, 6, 7], "snap": "all"},
    "fantasma_derrota": {"src": "fantasma", "grid": (3, 3), "who": "fantasma", "frames": [8], "measure": [0, 1, 2],
                         "ground": [8], "snap": "all"},
    # Boi foragido (vaca zumbi): raspa a pata, corre e dá chifrada
    "vaca_andando": {"src": "vaca", "grid": (3, 3), "who": "vaca", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "vaca_chifrada": {"src": "vaca", "grid": (3, 3), "who": "vaca", "frames": [3, 4, 5], "measure": [0, 1, 2],
                      "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "vaca_dano": {"src": "vaca", "grid": (3, 3), "who": "vaca", "frames": [6, 7], "measure": [0, 1, 2],
                  "ground": [6, 7], "snap": "all"},
    "vaca_derrota": {"src": "vaca", "grid": (3, 3), "who": "vaca", "frames": [8], "measure": [0, 1, 2],
                     "ground": [8], "snap": "all"},
    # Rato gigante: vira de costas e dá rabada
    "rato_andando": {"src": "rato", "grid": (3, 3), "who": "rato", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "rato_rabada": {"src": "rato", "grid": (3, 3), "who": "rato", "frames": [3, 4, 5], "measure": [0, 1, 2],
                    "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "rato_dano": {"src": "rato", "grid": (3, 3), "who": "rato", "frames": [6, 7], "measure": [0, 1, 2],
                  "ground": [6, 7], "snap": "all"},
    "rato_derrota": {"src": "rato", "grid": (3, 3), "who": "rato", "frames": [8], "measure": [0, 1, 2],
                     "ground": [8], "snap": "all"},
    # Chefe da fase 3: barata gigante da máquina de arroz (joga arroz envenenado)
    "barata_andando": {"src": "barata", "grid": (3, 3), "who": "barata", "frames": [0, 1, 2], "measure": [0, 1, 2],
                       "keep_border": True},
    "barata_arremesso": {"src": "barata", "grid": (3, 3), "who": "barata", "frames": [3, 4], "measure": [0, 1, 2],
                         "ground": [3, 4], "snap": "all", "keep_border": True},
    "barata_dano": {"src": "barata", "grid": (3, 3), "who": "barata", "frames": [6, 7], "measure": [0, 1, 2],
                    "ground": [6, 7], "snap": "all"},
    "barata_derrota": {"src": "barata", "grid": (3, 3), "who": "barata", "frames": [8], "measure": [0, 1, 2],
                       "ground": [8], "snap": "all"},
    # Vovô Nivaldo e vovó Berenice: presos chorando; livres e felizes
    "vovos_presos": {"src": "vovo_e_vovo", "grid": (3, 2), "who": "vovos", "frames": [0, 1, 2], "measure": [3, 4],
                     "ground": [0, 1, 2], "snap": "all"},
    "vovos_livres": {"src": "vovo_e_vovo", "grid": (3, 2), "who": "vovos", "frames": [3, 4, 5], "measure": [3, 4],
                     "ground": [3, 4]},
    # Fase 4: caranguejo (pinça), ermitão (atira espinhos), lagosta zumbi (bafo fedido)
    "caranguejo_andando": {"src": "carangueijo", "grid": (3, 3), "who": "caranguejo", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "caranguejo_ataque": {"src": "carangueijo", "grid": (3, 3), "who": "caranguejo", "frames": [3, 4, 5], "measure": [0, 1, 2],
                          "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "caranguejo_dano": {"src": "carangueijo", "grid": (3, 3), "who": "caranguejo", "frames": [6, 7], "measure": [0, 1, 2],
                        "ground": [6, 7], "snap": "all"},
    "caranguejo_derrota": {"src": "carangueijo", "grid": (3, 3), "who": "caranguejo", "frames": [8], "measure": [0, 1, 2],
                           "ground": [8], "snap": "all"},
    "ermitao_andando": {"src": "ermitao", "grid": (3, 3), "who": "ermitao", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "ermitao_ataque": {"src": "ermitao", "grid": (3, 3), "who": "ermitao", "frames": [3, 4], "measure": [0, 1, 2],
                       "ground": [3, 4], "snap": "all", "keep_border": True},
    "ermitao_dano": {"src": "ermitao", "grid": (3, 3), "who": "ermitao", "frames": [6, 7], "measure": [0, 1, 2],
                     "ground": [6, 7], "snap": "all"},
    "ermitao_derrota": {"src": "ermitao", "grid": (3, 3), "who": "ermitao", "frames": [8], "measure": [0, 1, 2],
                        "ground": [8], "snap": "all"},
    "lagosta_andando": {"src": "lagosta", "grid": (3, 3), "who": "lagosta", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "lagosta_ataque": {"src": "lagosta", "grid": (3, 3), "who": "lagosta", "frames": [3, 4], "measure": [0, 1, 2],
                       "ground": [3, 4], "snap": "all", "keep_border": True},
    "lagosta_dano": {"src": "lagosta", "grid": (3, 3), "who": "lagosta", "frames": [6, 7], "measure": [0, 1, 2],
                     "ground": [6, 7], "snap": "all"},
    "lagosta_derrota": {"src": "lagosta", "grid": (3, 3), "who": "lagosta", "frames": [8], "measure": [0, 1, 2],
                        "ground": [8], "snap": "all"},
    # Chefe da fase 4: estrela do mar
    "estrela_andando": {"src": "estrela", "grid": (3, 3), "who": "estrela", "frames": [1, 2], "measure": [1, 2]},
    "estrela_danca": {"src": "estrela", "grid": (3, 3), "who": "estrela", "frames": [0], "measure": [1, 2],
                      "ground": [0], "snap": "all"},
    "estrela_ataque": {"src": "estrela", "grid": (3, 3), "who": "estrela", "frames": [3, 4, 5], "measure": [1, 2],
                       "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "estrela_dano": {"src": "estrela", "grid": (3, 3), "who": "estrela", "frames": [6, 7], "measure": [1, 2],
                     "ground": [6, 7], "snap": "all"},
    "estrela_derrota": {"src": "estrela", "grid": (3, 3), "who": "estrela", "frames": [8], "measure": [1, 2],
                        "ground": [8], "snap": "all"},
    # Papai e mamãe: presos chorando; livres e felizes
    "pais_presos": {"src": "mamae_papai", "grid": (3, 2), "who": "pais", "frames": [0, 1, 2], "measure": [3, 4],
                    "ground": [0, 1, 2], "snap": "all"},
    "pais_livres": {"src": "mamae_papai", "grid": (3, 2), "who": "pais", "frames": [3, 4, 5], "measure": [3, 4],
                    "ground": [3, 4]},
    # Fase 5: arara (voa; bafo fedido), preguiça (garra mágica), hipopótamo zumbi (bafo)
    "arara_andando": {"src": "caio", "grid": (3, 3), "who": "arara", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "arara_ataque": {"src": "caio", "grid": (3, 3), "who": "arara", "frames": [3, 4, 5], "measure": [0, 1, 2],
                    "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "arara_dano": {"src": "caio", "grid": (3, 3), "who": "arara", "frames": [6, 7], "measure": [0, 1, 2],
                  "ground": [6, 7], "snap": "all"},
    "arara_derrota": {"src": "caio", "grid": (3, 3), "who": "arara", "frames": [8], "measure": [0, 1, 2],
                     "ground": [8], "snap": "all", "keep_border": True},
    "preguica_andando": {"src": "pre", "grid": (3, 3), "who": "preguica", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "preguica_ataque": {"src": "pre", "grid": (3, 3), "who": "preguica", "frames": [3, 4, 5], "measure": [0, 1, 2],
                    "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "preguica_dano": {"src": "pre", "grid": (3, 3), "who": "preguica", "frames": [6, 7], "measure": [0, 1, 2],
                  "ground": [6, 7], "snap": "all"},
    "preguica_derrota": {"src": "pre", "grid": (3, 3), "who": "preguica", "frames": [8], "measure": [0, 1, 2],
                     "ground": [8], "snap": "all", "keep_border": True},
    "hipopotamo_andando": {"src": "jj", "grid": (3, 3), "who": "hipopotamo", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "hipopotamo_ataque": {"src": "jj", "grid": (3, 3), "who": "hipopotamo", "frames": [3, 4, 5], "measure": [0, 1, 2],
                    "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "hipopotamo_dano": {"src": "jj", "grid": (3, 3), "who": "hipopotamo", "frames": [6, 7], "measure": [0, 1, 2],
                  "ground": [6, 7], "snap": "all"},
    "hipopotamo_derrota": {"src": "jj", "grid": (3, 3), "who": "hipopotamo", "frames": [8], "measure": [0, 1, 2],
                     "ground": [8], "snap": "all", "keep_border": True},
    # Chefe da fase 5: sagui zumbi (joga bananas)
    "sagui_andando": {"src": "sa_f", "grid": (3, 3), "who": "sagui", "frames": [0, 1, 2], "measure": [0, 1, 2]},
    "sagui_ataque": {"src": "sa_f", "grid": (3, 3), "who": "sagui", "frames": [3, 4, 5], "measure": [0, 1, 2],
                    "ground": [3, 4, 5], "snap": "all", "keep_border": True},
    "sagui_dano": {"src": "sa_f", "grid": (3, 3), "who": "sagui", "frames": [6, 7], "measure": [0, 1, 2],
                  "ground": [6, 7], "snap": "all"},
    "sagui_derrota": {"src": "sa_f", "grid": (3, 3), "who": "sagui", "frames": [8], "measure": [0, 1, 2],
                     "ground": [8], "snap": "all", "keep_border": True},
    # Prisioneira da fase 5: presa chorando; livre e feliz
    "vovo_bosque_presa": {"src": "vovovo", "grid": (3, 2), "who": "vovo_bosque", "frames": [0, 1, 2], "measure": [3, 4],
                          "ground": [0, 1, 2], "snap": "all"},
    "vovo_bosque_livre": {"src": "vovovo", "grid": (3, 2), "who": "vovo_bosque", "frames": [3, 4, 5], "measure": [3, 4],
                          "ground": [3, 4]},
    # Bruxa
    "bruxa_andando": {"src": "Bruxa_Andando", "grid": (3, 3), "who": "bruxa"},
    "bruxa_entrada": {"src": "Bruxa_Entrada", "grid": (3, 2), "who": "bruxa",
                      "measure": [5], "ground": [2, 4, 5], "snap": "none"},
    "bruxa_vassourada": {"src": "Bruxa_Vassourada", "grid": (3, 2), "who": "bruxa",
                         "measure": [1, 4, 5], "keep_border": True},
    "bruxa_magia": {"src": "Bruxa_Magia", "grid": (3, 3), "who": "bruxa", "keep_border": True},
    "bruxa_dano": {"src": "Bruxa_Dano", "grid": (3, 2), "who": "bruxa",
                   "measure": [0, 1], "ratio": 1.1, "erase": [(0, 0, 1, 0.14)]},
    "bruxa_derrota": {"src": "Bruxa_Derrota", "grid": (3, 3), "who": "bruxa",
                      "frames": [0, 1, 2, 6, 7, 8], "measure": [0], "ground": [0, 1, 2], "snap": "none"},
    "bruxa_invocando": {"src": "Bruxa_Invocando", "grid": (3, 2), "who": "bruxa",
                        "measure": [1, 2, 5]},
}

LINE_DARK = 200        # soma RGB abaixo disto conta como pixel de linha
LINE_FRACTION = 0.45   # fração mínima de pixels escuros para ser uma linha
SNAP_TOLERANCE = 0.035  # fração da altura da célula
MIN_SPECK = 60         # componentes menores que isto (em pixels, meia resolução) somem
OUTPUT_SCALE_LIMIT = 1.0
PADDING = 4


# --- 1. Linhas da grade ---------------------------------------------------

def find_lines(image, axis):
    """Faixas [início, fim] de linhas escuras no eixo (0 = verticais, 1 = horizontais)."""
    pixels = image.load()
    width, height = image.size
    length, span = (width, height) if axis == 0 else (height, width)
    marks = []
    for pos in range(length):
        dark = total = 0
        for other in range(0, span, 3):
            color = pixels[pos, other] if axis == 0 else pixels[other, pos]
            total += 1
            if sum(color) < LINE_DARK:
                dark += 1
        marks.append(dark / total)
    bands = []
    pos = 0
    while pos < length:
        if marks[pos] >= LINE_FRACTION:
            start = end = pos
            while start > 0 and marks[start - 1] >= 0.25:
                start -= 1
            while end + 1 < length and marks[end + 1] >= 0.25:
                end += 1
            if end - start <= 16:
                bands.append((start, end))
            pos = end + 1
        else:
            pos += 1
    return bands


def erase_lines(image, bands, axis):
    """Preenche cada faixa interpolando as cores dos dois lados."""
    pixels = image.load()
    width, height = image.size
    length, span = (width, height) if axis == 0 else (height, width)
    for start, end in bands:
        a = max(0, start - 3)
        b = min(length - 1, end + 3)
        for other in range(span):
            ca = pixels[a, other] if axis == 0 else pixels[other, a]
            cb = pixels[b, other] if axis == 0 else pixels[other, b]
            for pos in range(a + 1, b):
                t = (pos - a) / (b - a)
                color = tuple(int(ca[c] + (cb[c] - ca[c]) * t) for c in range(3))
                if axis == 0:
                    pixels[pos, other] = color
                else:
                    pixels[other, pos] = color


def cell_edges(length, count, bands):
    """Bordas das células: divisão igual, ajustada à linha detectada mais próxima."""
    edges = [0]
    for i in range(1, count):
        expected = length * i / count
        best = None
        for start, end in bands:
            center = (start + end) / 2
            if abs(center - expected) < length * 0.05 and (best is None or abs(center - expected) < abs(best - expected)):
                best = center
        edges.append(round(best if best is not None else expected))
    edges.append(length)
    return edges


# --- 3. Fundo magenta e sombras -------------------------------------------

def key_out(cell):
    """Remove o magenta e as sombras roxas (magenta escuro). Retorna RGBA."""
    cell = cell.convert("RGBA")
    pixels = cell.load()
    width, height = cell.size
    for y in range(height):
        for x in range(width):
            r, g, b, _ = pixels[x, y]
            low = min(r, b)
            if low < 28:
                continue
            # Fundo e sombra: vermelho e azul parecidos, quase sem verde.
            # (Rosa/roxo dos personagens tem verde ou vermelho bem maior que azul.)
            if abs(r - b) > 0.25 * max(r, b):
                continue
            ratio = g / low
            if ratio < 0.12:
                pixels[x, y] = (0, 0, 0, 0)
            elif ratio < 0.3:
                k = (ratio - 0.12) / 0.18
                # Tira o rosa da borda e deixa semitransparente.
                r = int(g + (r - g) * k)
                b = int(g + (b - g) * k)
                pixels[x, y] = (r, g, b, int(255 * k))
    return cell


# --- 4. Componentes --------------------------------------------------------

def components(cell):
    """Componentes conectados da máscara (em meia resolução, para ser rápido)."""
    alpha = cell.getchannel("A")
    small = alpha.resize((max(1, cell.width // 2), max(1, cell.height // 2)), Image.NEAREST)
    width, height = small.size
    data = small.load()
    labels = [[-1] * width for _ in range(height)]
    found = []
    for y in range(height):
        for x in range(width):
            if data[x, y] < 64 or labels[y][x] >= 0:
                continue
            index = len(found)
            queue = deque([(x, y)])
            labels[y][x] = index
            area = 0
            x0, y0, x1, y1 = x, y, x, y
            while queue:
                cx, cy = queue.popleft()
                area += 1
                x0, x1 = min(x0, cx), max(x1, cx)
                y0, y1 = min(y0, cy), max(y1, cy)
                for nx in (cx - 1, cx, cx + 1):
                    for ny in (cy - 1, cy, cy + 1):
                        if 0 <= nx < width and 0 <= ny < height and labels[ny][nx] < 0 and data[nx, ny] >= 64:
                            labels[ny][nx] = index
                            queue.append((nx, ny))
            found.append({"area": area, "box": (x0, y0, x1, y1)})
    return labels, found, (width, height)


def defringe(cell, passes):
    """Apaga a franja rosada (mistura de magenta) nas bordas, uma camada por passada."""
    pixels = cell.load()
    width, height = cell.size
    for _ in range(passes):
        remove = []
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                if a == 0 or b - g <= 30 or r < 120:
                    continue
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if 0 <= nx < width and 0 <= ny < height and pixels[nx, ny][3] < 128:
                        remove.append((x, y))
                        break
        for x, y in remove:
            pixels[x, y] = (0, 0, 0, 0)


def clean(cell, keep_border):
    """Remove pedacinhos soltos e invasões de quadros vizinhos. Retorna (cell, caixa do corpo)."""
    labels, found, (width, height) = components(cell)
    if not found:
        return cell, None
    body = max(range(len(found)), key=lambda i: found[i]["area"])
    keep = set()
    for index, comp in enumerate(found):
        if index == body:
            keep.add(index)
            continue
        if comp["area"] < MIN_SPECK:
            continue
        x0, y0, x1, y1 = comp["box"]
        touches = x0 <= 1 or y0 <= 1 or x1 >= width - 2 or y1 >= height - 2
        if touches and not keep_border:
            continue
        keep.add(index)
    pixels = cell.load()
    for y in range(cell.height):
        row = labels[min(y // 2, height - 1)]
        for x in range(cell.width):
            if pixels[x, y][3] and row[min(x // 2, width - 1)] not in keep:
                # Pixels de borda semitransparentes podem cair fora da máscara: vizinhança decide.
                if row[min(x // 2, width - 1)] == -1 and _near_kept(labels, keep, x // 2, y // 2, width, height):
                    continue
                pixels[x, y] = (0, 0, 0, 0)
    x0, y0, x1, y1 = found[body]["box"]
    return cell, (x0 * 2, y0 * 2, x1 * 2 + 2, y1 * 2 + 2)


def _near_kept(labels, keep, x, y, width, height):
    for nx in (x - 1, x, x + 1):
        for ny in (y - 1, y, y + 1):
            if 0 <= nx < width and 0 <= ny < height and labels[ny][nx] in keep:
                return True
    return False


# --- Montagem --------------------------------------------------------------

def erase_rects(cell, rects):
    draw = ImageDraw.Draw(cell)
    for x0, y0, x1, y1 in rects:
        draw.rectangle((x0 * cell.width, y0 * cell.height, x1 * cell.width, y1 * cell.height), fill=(255, 0, 255))


def median(values):
    values = sorted(values)
    middle = len(values) // 2
    return values[middle] if len(values) % 2 else (values[middle - 1] + values[middle]) / 2


def build(name, info):
    path = f"images/{info['src']}.jpeg"
    if not os.path.exists(path):
        path = f"images/{info['src']}.png"
    image = Image.open(path).convert("RGB")
    cols, rows = info["grid"]
    vertical = find_lines(image, 0)
    horizontal = find_lines(image, 1)
    erase_lines(image, vertical, 0)
    erase_lines(image, horizontal, 1)
    xs = cell_edges(image.width, cols, vertical)
    ys = cell_edges(image.height, rows, horizontal)

    order = info.get("frames", list(range(cols * rows)))
    measure = info.get("measure", order)
    ground_frames = info.get("ground", measure)
    # Quadros de medida podem ficar fora de "frames" (várias animações da mesma
    # grade com a mesma escala): são processados, mas não vão para a folha.
    wanted = order + [i for i in measure + ground_frames if i not in order]
    wanted = list(dict.fromkeys(wanted))
    erase = info.get("erase", [])
    cells = []
    for index in wanted:
        col, row = index % cols, index // cols
        cell = image.crop((xs[col], ys[row], xs[col + 1], ys[row + 1]))
        rects = erase.get(index, []) if isinstance(erase, dict) else erase
        erase_rects(cell, rects)
        cell = key_out(cell)
        if info.get("defringe"):
            defringe(cell, info["defringe"])
        cell, body = clean(cell, info.get("keep_border", False))
        if body is None:
            raise SystemExit(f"{name}: quadro {index} vazio")
        cells.append((index, cell, body))

    # Escala: altura do corpo nos quadros de medida = altura do personagem * ratio.
    if "width" in info:
        widths = [body[2] - body[0] for index, _, body in cells if index in measure]
        scale = info["width"] / median(widths)
    else:
        heights = [body[3] - body[1] for index, _, body in cells if index in measure]
        target = HEIGHTS[info["who"]] * info.get("ratio", 1.0)
        scale = target / median(heights)

    # Pés: x = centro médio do corpo; y = linha do chão dos quadros "ground".
    anchor_x = median([(body[0] + body[2]) / 2 for index, _, body in cells if index in measure])
    ground = median([body[3] for index, _, body in cells if index in ground_frames])
    snap = info.get("snap", "tol")

    placed = []
    for index, cell, body in cells:
        if index not in order:
            continue
        box = cell.getchannel("A").getbbox()
        frame = cell.crop(box)
        frame = frame.convert("RGBa").resize(
            (max(1, round(frame.width * scale)), max(1, round(frame.height * scale))), Image.LANCZOS).convert("RGBA")
        # Posição do quadro em relação aos pés (em pixels da saída).
        dx = (box[0] - anchor_x) * scale
        offset = body[3] - ground
        if snap == "all" or (snap == "tol" and abs(offset) < SNAP_TOLERANCE * cell.height):
            offset = 0
        dy = (box[1] - body[3] + offset) * scale
        placed.append((frame, dx, dy))

    left = min(dx for _, dx, _ in placed)
    right = max(dx + f.width for f, dx, _ in placed)
    top = min(dy for _, _, dy in placed)
    bottom = max(dy + f.height for f, _, dy in placed)
    feet = (round(-left) + PADDING, round(-top) + PADDING)
    cell_w = round(right - left) + PADDING * 2
    cell_h = round(bottom - top) + PADDING * 2
    sheet = Image.new("RGBA", (cell_w * len(placed), cell_h), (0, 0, 0, 0))
    for i, (frame, dx, dy) in enumerate(placed):
        sheet.alpha_composite(frame, (i * cell_w + feet[0] + round(dx), feet[1] + round(dy)))
    sheet.save(f"art/{name}.png")
    print(f"{name}: {len(placed)} quadros, célula {cell_w}x{cell_h}, pés {feet}, escala {scale:.3f}")
    return {"frames": len(placed), "cell": [cell_w, cell_h], "feet": list(feet)}


def preview(manifest):
    """Todas as folhas numa imagem só, com os pés marcados, para conferir."""
    rows = []
    for name in sorted(manifest):
        sheet = Image.open(f"art/{name}.png")
        info = manifest[name]
        canvas = Image.new("RGBA", sheet.size, (120, 200, 120, 255))
        canvas.alpha_composite(sheet)
        draw = ImageDraw.Draw(canvas)
        cw = info["cell"][0]
        fx, fy = info["feet"]
        for i in range(info["frames"]):
            draw.line((i * cw, fy, (i + 1) * cw, fy), fill=(255, 0, 0, 255))
            draw.line((i * cw + fx, fy - 10, i * cw + fx, fy + 10), fill=(0, 0, 255, 255))
            draw.rectangle((i * cw, 0, (i + 1) * cw - 1, info["cell"][1] - 1), outline=(60, 60, 60, 255))
        draw.text((3, 3), name, fill=(0, 0, 0, 255))
        rows.append(canvas)
    width = max(r.width for r in rows)
    out = Image.new("RGBA", (width, sum(r.height for r in rows)), (255, 255, 255, 255))
    y = 0
    for r in rows:
        out.alpha_composite(r, (0, y))
        y += r.height
    out.save("tools/_preview.png")
    print("tools/_preview.png")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    os.makedirs("art", exist_ok=True)
    manifest_path = "art/sprites.json"
    manifest = {}
    if os.path.exists(manifest_path):
        with open(manifest_path) as f:
            manifest = json.load(f)
    for name in args or SHEETS:
        if name not in SHEETS:
            raise SystemExit(f"folha desconhecida: {name}")
        manifest[name] = build(name, SHEETS[name])
    manifest = {k: manifest[k] for k in sorted(manifest) if k in SHEETS}
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=1)
    if "--preview" in sys.argv:
        preview(manifest)


if __name__ == "__main__":
    main()
