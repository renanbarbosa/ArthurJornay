# Contexto exportado — Arthur: Caminho de Volta

Use este documento como contexto inicial ao continuar o projeto no Claude.

## Objetivo do projeto

Arthur: Caminho de Volta é um protótipo 2D jogável com cinco fases, **Praça da Bruxa**, **Rua Padre Vieira**, **Itaporanga**, **Salvador** e **Bosque dos Jequitibás**, desenvolvido com Godot 4.2 ou superior. O visual é desenhado integralmente por código, sem assets externos.

## Estado atual

- Projeto executado localmente com Godot 4.7.2 via Flatpak.
- Arquivos principais criados no repositório: `project.godot`, `Main.tscn`, `main.gd` e `main.gd.uid`.
- `README.md` foi atualizado com descrição, execução e controles.
- O repositório possui mudanças não confirmadas (arquivos novos e README modificado).
- Não há uma suíte de testes automatizados configurada.

## Estrutura relevante

- `project.godot`: configuração da aplicação, resolução 960×540, cena principal `res://Main.tscn` e renderizador de compatibilidade.
- `Main.tscn`: cena raiz `Node2D` chamada `Game`, ligada ao script `res://main.gd`.
- `main.gd`: gameplay, câmera lateral, inimigos, chefe, HUD, desenho procedural e sistema de resgate.
- `README.md`: instruções de execução e controles.
- `main.gd.uid`: UID do script no Godot.

## Como executar

Abrir o projeto no Godot:

```bash
flatpak run org.godotengine.Godot --path /home/renan/IA/ArthurJornay
```

No editor: pressione F6 para executar a cena principal ou F5 para iniciar o projeto.

## Controles

- Mover horizontalmente: setas esquerda/direita ou A/D (segurando 0,45 s, Arthur corre 45% mais rápido).
- Mudar de faixa: setas cima/baixo ou W/S.
- Pular: Espaço.
- Soco: J (o inimigo mais perto à frente). Chute giratório: K (todos em volta, inclusive atrás; recarga 0,55 s).
- Pum Poderoso: Q; recarga de 7 segundos; atordoa inimigos e o chefe.
- Super Espetinho: E; recarga de 18 segundos; remove inimigos e causa dano ao chefe.
- Defender: segurar L ou Shift (reduz o dano em 80%, empurra o inimigo, deixa Arthur lento e impede ataques).
- Reiniciar após vencer: Enter.
- Controle (gamepad, padrão Xbox): direcional ou analógico esquerdo anda; A pula, X soco, Y chute, B ou gatilho esquerdo defende, LB pum, RB espetinho, Start confirma/próxima fase, Back abre o menu de fases. O mapeamento fica em `PAD_BUTTONS` no `main.gd` (teclado e controle passam por `_game_action`); `PAD_DEBUG` imprime o número dos botões.

## Mecânicas implementadas

- Movimento horizontal com câmera lateral.
- Movimento em três posições de faixa.
- Pulo com gravidade simples.
- Ondas de inimigos acionadas pela progressão horizontal.
- Inimigos perseguem o jogador (também mudam de faixa) e atacam de perto com animação; o golpe acerta num quadro específico (`hit_frame`). Nocauteados saem voando e somem.
- Fases em `PHASES` (main.gd): fundos, ordem sorteada ou alternada, arena, ondas e chefe; chefes em `BOSSES` (vida, velocidade, animações e tempos de melee/ranged/summon, ajudante, projétil "magic" ou "curse"). Estados do chefe: entrance, walk, melee, ranged, summon, defeat. O jogo abre na tela de escolha de fase (`choosing_phase`, `menu_index`, `_draw_phase_menu`: cartões com a arena e o chefe; setas/1-9/ENTER); ESC no jogo volta para ela. ENTER após vencer vai para a próxima fase (da última volta à primeira); `-- --fase=N` pula a escolha. O primeiro cartão do menu é a história (`menu_index == MENU_STORY`, -1; tecla 0/H): `watching_story`, `story_index`, `story_time`, `STORY_TEXTS` (20 textos), `story_scene_time` (STORY_BASE_TIME + letras/STORY_READ_SPEED), `_draw_story` (fundo desfocado, imagem com zoom e deslize, esmaecer de STORY_FADE_TIME, texto subindo à direita), `_story_input` (ENTER/→ próxima, ← volta, ESC menu; na última ENTER começa a fase 1). Imagens `art/historia_N.jpg` e `art/historia_N_fundo.jpg` geradas de `images/H_N.jpeg` por `tools/build_historia.py`; `-- --historia` abre direto.
- Chefe da fase 1, **Bruxa da Praça**, com 24 pontos de vida (`BOSSES["bruxa"]`, pelo menos 20 golpes): entrada voando (sem dano), anda até o Arthur, magia de longe (bola verde, dá para pular), vassourada de perto, invoca cachorro com 16 e 8 de vida (`summon_at`), animação de dano/enjoo e derrota (foge voando) antes da vitória.
- Soco e chute: 1 dano por golpe a inimigos ou chefe.
- Pum Poderoso: atordoa inimigos por 2 segundos e o chefe por 1,4 segundo.
- Super Espetinho: limpa todos os inimigos e causa 2 danos ao chefe.
- Energia máxima de 100.
- A personagem Doroth resgata Arthur indefinidamente quando a energia chega a zero:
  - restaura 100 de energia;
  - concede invulnerabilidade;
  - remove inimigos;
  - causa 2 danos ao chefe se ele estiver ativo.
- Ao derrotar a bruxa, a tela de vitória é exibida.
- Obstáculos (`_build_obstacles` em `main.gd`, cocô e banco alternados a cada 430 px, faixas em `OBSTACLE_LANES`): cocô (`art/coco.png`, fedendo com moscas; amassa quando o Arthur pisa) deixa Arthur 60% mais lento (pular ou trocar de faixa evita); bancos (`art/banco.png`) bloqueiam, mas Arthur pode pular e ficar em cima (altura 38), fora do alcance dos inimigos.
- Fase 1 com fundo de imagens: sequência praca_1, praca_2 (×7) + praca_3 (arena), 15 telas = 12160 px lógicos (~2 min até a bruxa); `tools/build_backgrounds.py` alinha o chão (cerca viva termina em y 318, grama em 528) e gera `art/praca_N.jpg`; na fase 2 usa quatro linhas por imagem (grade, topo do muro, pé do muro = chão em y 318, meio-fio) e gera `art/rua_*.jpg`. Emendas misturadas em 160 px. Bruxa aparece ao entrar na praca_3 (x ≥ 11300), câmera trava em 11200 e o Arthur fica preso na arena.
- Fase 2, **Rua Padre Vieira**: fundos `rua_1..3` sorteados (sem repetir seguido) + `rua_final` (viaduto, arena). Inimigos: gordão do espetinho (4 de vida, alcance 115), morador de rua com faca (3 de vida, rápido) e motoqueiro de entregas (`rider`: placa "BIBI!" na borda por 1,3 s acompanhando a faixa do Arthur, depois atravessa a 430 px/s; pulo acima de 45 escapa; golpe, pum ou latido derrubam). Chefe **Praga da Rua** (26 de vida): entra mancando pela direita, xinga de longe (balão "#@$%!"), muletada de perto, chama morador com 18 e 9 de vida, fica verde no pum, cai sentado na derrota.
- Fase 3, **Itaporanga**: fundos `cidade_1..3` sorteados + `cidade_final` (máquina de arroz, pôr do sol). Inimigos: fantasma (3 de vida, `hover`: flutua 18 px), vaca zumbi (5 de vida, dano 18, `lunge`: avança na chifrada) e rato gigante (3 de vida, rápido, rabada). Chefe **Barata Gigante** (28 de vida): entra andando pela direita, joga arroz envenenado (projétil "rice", também como golpe de perto), chama rato com 20 e 10 de vida, cai de costas; `defeat_time` 3,5 s para ver os vovós. Prisioneiros da fase (`captives` em PHASES, posição `CAPTIVES_X`/`CAPTIVES_LANE`): vovô Nivaldo e vovó Berenice, `vovos_presos` (chorando, às vezes se abraçam) até a derrota do chefe, depois `vovos_livres` (correntes quebram, acenam, pulam); `captives_frame()` diz o quadro. O par é desenhado centralizado em `CAPTIVES_X` (o ponto dos pés da folha fica num dos dois).
- Fase 4, **Salvador**: fundos `salvador_1..3` sorteados + `salvador_final` (resort; o calçadão é bem baixo na imagem e ficou mais esticado). Inimigos: caranguejo (3 de vida, pinça), ermitão (`shooter`: para a 300 px e atira espinho "spike", SPIKE_SPEED 420, dano 10) e lagosta zumbi (4 de vida, bafo com alcance 150). Chefe **Estrela do Mar** (30 de vida): braçada de perto, estrelinha "star" de longe, dança (`estrela_danca`) e chama caranguejo com 22 e 11. Prisioneiros: papai e mamãe (`pais_presos`/`pais_livres`). Projéteis podem ter "damage" próprio.
- Fase 5, **Bosque dos Jequitibás**: fundos `bosque_1..3` sorteados + `bosque_final` (jaula do hipopótamo). Arquivos de origem com nomes curtos: `caio.jpeg` = arara (2 de vida, rápida, `hover` 45 com `hover_moving`: só voa andando, pousa para o bafo), `pre.jpeg` = preguiça (5 de vida, lenta, garra forte), `jj.jpeg` = hipopótamo zumbi (6 de vida, bafo alcance 150), `sa_f.jpeg` = chefe **Sagui Zumbi** (32 de vida, banana "banana" de longe, chama arara com 24 e 12), `vovovo.jpeg` = vovó prisioneira (`vovo_bosque_presa`/`vovo_bosque_livre`; uma pessoa só). Cartões do menu ajustam o tamanho do nome da fase.
- Inimigos: tipos em `ENEMY_TYPES` (vida, velocidade, alcance, dano, recarga e animações run/attack/idle/hurt/sick/spawn/ko, sick_tint, ko_time, rider) e ondas em "waves" de cada fase em `PHASES` (main.gd). 15 ondas a cada 720 px a partir de x 600 (`WAVE_START`, `WAVE_SPACING`), ficando mais difíceis. Pitbull (2 de vida), chihuahua (1, rápido) e cachorro da bruxa (5 de vida, dano 18, surge numa nuvem). Estados: spawn, chase, idle, attack, stunned (hurt ou sick), ko.
- Área de movimento: lanes de -0.92 a 1.35 (y 336 a 513), sobre as lajotinhas. Bancos e personagens são desenhados ordenados por profundidade.
- Janela 1920×1080 com área lógica 960×540 (stretch `canvas_items`).
- Poderes extensíveis: cada poder é um script em `powers/` que estende `powers/power.gd` e é registrado em `POWER_SCRIPTS`. Doroth também é um poder, sem tecla, acionado pelo jogo.
- Sprites: folhas em grade do Nano Banana em `images/` (fundo magenta), convertidas por `tools/build_sprites.py` (lista `SHEETS`) em `art/<nome>.png` + `art/sprites.json` (quadros e pés). O jogo carrega o manifesto em `_load_anims` e desenha tudo com `SPRITE_SCALE` 0.5 (sprites no dobro do tamanho lógico); velocidades em `ANIM_SPEED`. Arthur: parado, andando, correndo, pulo, ataque, defesa (quadros 3–5 = dor), comemora, pum, espetinho. Dorothy: parada, correndo, lambida, latido. Bruxa: andando, entrada, vassourada, magia, dano (0–1 dano, 2–5 enjoo), derrota, invocando. Se faltarem, o jogo volta ao desenho procedural.
- Doroth passeia aleatoriamente pelo cenário (correndo ou parada). Resgate (estados RUSH, LICK, BARK em `powers/doroth_power.gd`): Arthur cai derrotado (`arthur_derrotado` 0-2 caindo, 3-4 tonto) enquanto ela corre com raios na tela; ela lambe o rosto dele por 2 s com corações subindo pela tela e a energia enchendo aos poucos (`set_energy`); depois late (inimigos derrubados e 2 de dano na bruxa aos 0,6 s) e Arthur senta (quadro 5) e levanta. O poder controla a animação do Arthur por `player_frame` (gancho de `power.gd`).
- HUD com imagens: `hud_barra` + rosto `hud_arthur` (`hud_face`) à esquerda; `hud_comandos` + `hud_icones` (J, K, L, E, Q, Doroth) à direita, com recarga escurecendo o ícone. Posições medidas nas imagens (`HUD_BAR_FILL`, `HUD_SUN_CENTER`, `HUD_SLOT_*`). Sem as imagens, `_draw_simple_hud`.
- Arthur parado usa só os 3 primeiros quadros de Arthur_Parado.
- Pum: gosma verde escorre do alto da tela e aparecem manchas verdes (2,8 s); a pose do Arthur dura 0,99 s (`pose_duration`); inimigos e bruxa ficam enjoados (`stun_enemies(s, true)`).
- Pum e Super Espetinho tocam a animação do Arthur e o deixam parado enquanto duram; o Arthur come o espetinho, fica vermelho e o fogo só elimina os inimigos quando sai da boca (0,78 s).

## Arquitetura do `main.gd`

O arquivo usa `Node2D` com `_ready`, `_input`, `_process` e `_draw`.

Principais funções:

- `_process`: atualiza tempo, movimento, pulo, cooldowns, ondas e entidades.
- `_control`: movimento, corrida, defesa e pulo a partir das teclas.
- `_spawn_progress` / `spawn_enemy`: ondas de inimigos e ativação do chefe.
- `_update_enemies`: máquina de estados dos inimigos.
- `_update_boss` / `_update_projectiles`: máquina de estados da bruxa e bolas de magia.
- `_attack(kind)`: soco ("punch") ou chute giratório ("kick"), configurados em `ATTACKS`.
- `_take_hit`: dano (defesa reduz) e acionamento da Doroth.
- `player_frame`, `enemy_frame`, `boss_frame`: escolhem animação e quadro de cada personagem.
- Poderes em `powers/` (pum, espetinho, Doroth).
- `_restart`: reinicializa todo o estado da partida.
- `_draw_*`: renderização procedural do cenário, personagens, chefe, HUD e vitória.

## Estado Git

Saída conhecida do `git status`:

```text
## main...origin/main
 M README.md
?? Main.tscn
?? main.gd
?? main.gd.uid
?? project.godot
```

Portanto, o código ainda não foi confirmado em uma ou mais alterações novas.

## Caminho local

`/home/renan/IA/ArthurJornay`

## Solicitações anteriores nesta conversa

1. “rode o prototipo” — o usuário pediu para abrir o jogo.
2. Resultado: o projeto foi executado com `flatpak run org.godotengine.Godot --path /home/renan/IA/ArthurJornay` usando Godot 4.7.2, e a execução foi encerrada ao final da operação.
3. “exporte esse contexto para eu importar no meu claude” — gere um contexto portátil neste arquivo.

## Orientação para continuar no Claude

Antes de alterar o projeto, preservem o comportamento atual do protótipo e evitem adicionar dependências ou assets externos. Para mudanças, prefira:

- editar `main.gd` para gameplay e desenho;
- editar `Main.tscn` apenas para ajustes da cena;
- editar `project.godot` para configuração global;
- atualizar `README.md` para documentação diretamente relacionada;
- validar a alteração abrindo/executando o projeto no Godot.
