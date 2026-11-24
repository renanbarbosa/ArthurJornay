#!/usr/bin/env python3
"""Prepara as imagens de fundo das fases (images/*.jpeg) para o jogo.

Uso:
    python3 tools/build_backgrounds.py            # todas
    python3 tools/build_backgrounds.py rua_1      # só algumas

Para cada imagem:
  1. Suaviza a "caixa" da cena quando o gerador deixou faixas laterais de céu liso.
  2. Reposiciona as faixas na vertical para todas terem o chão na mesma altura
     do jogo: o chão começa em CURB_Y (fim da cerca viva / do muro).
  3. Salva em art/<nome>.jpg com 1920x1080 (o dobro da área lógica 960x540).

As linhas de cada imagem (na escala 1376x768) ficam em IMAGES. Se trocar uma
imagem, meça de novo as linhas. Duas formas:
  "curb"/"grass": onde a cerca viva termina e onde a grama começa (praça);
  "lines": pares (linha na imagem, linha na saída 1920x1080); as faixas entre
           elas são esticadas ou encolhidas (fase 2: cerca, muro, calçada, rua).

Requer Pillow (python3-pil).
"""
import os
import sys

from PIL import Image

WORK_SIZE = (1376, 768)
OUT_SIZE = (1920, 1080)
# Posições no jogo (área lógica 960x540), multiplicadas por 2 na saída.
CURB_Y = 318 * 2
GRASS_Y = 528 * 2
FEATHER = 140

# Linhas da fase 2 na saída: topo da grade, base da grade (topo do muro),
# pé do muro (começo da calçada = CURB_Y), meio-fio (começo da rua).
RUA = [496, 538, CURB_Y, 952]
# Fases 3 e 4: começo da calçada (= CURB_Y), meio-fio, começo da rua (ou da areia).
CIDADE = [CURB_Y, 930, 975]
# Fase 5: começo do caminho de pedras (= CURB_Y), meio-fio, grama.
BOSQUE = [CURB_Y, 1030, 1052]

IMAGES = {
    # nome de saída: arquivo de origem, linhas e bordas da "caixa" de cena a
    #                suavizar: (x, lado, até y)
    "praca_1": {"src": "praca_1", "curb": 526, "grass": 740, "boxes": [(172, "left", 456), (1204, "right", 456)]},
    "praca_2": {"src": "praca_2", "curb": 526, "grass": 740, "boxes": [(172, "left", 456), (1204, "right", 456)]},
    "praca_3": {"src": "praca_3", "curb": 526, "grass": 740, "boxes": [(172, "left", 456)]},
    # Fase 2: Rua Padre Vieira (rua_1..3 aparecem em ordem aleatória; rua_final é a arena)
    "rua_1": {"src": "bacK_1", "lines": [424, 467, 571, 694], "boxes": []},
    "rua_2": {"src": "back_2", "lines": [472, 512, 605, 720], "boxes": [(172, "left", 295), (1204, "right", 470)]},
    "rua_3": {"src": "back_3", "lines": [472, 512, 605, 720], "boxes": [(172, "left", 275), (1204, "right", 470)]},
    "rua_final": {"src": "final", "lines": [472, 512, 605, 720], "boxes": [(172, "left", 470)]},
    # Fase 3: Itaporanga (cidade_1..3 em ordem aleatória; cidade_final é a máquina de arroz).
    # "crop": faixa (x0, x1) usada, quando as laterais da imagem vieram com outra cor.
    "cidade_1": {"src": "back1", "crop": (107, 1269), "lines": [568, 678, 696], "targets": CIDADE, "boxes": []},
    "cidade_2": {"src": "back2", "lines": [567, 643, 660], "targets": CIDADE, "boxes": []},
    "cidade_3": {"src": "back3", "lines": [588, 686, 705], "targets": CIDADE, "boxes": []},
    "cidade_final": {"src": "maquina", "lines": [537, 681, 694], "targets": CIDADE, "boxes": []},
    # Fase 4: Salvador (orla: começo do calçadão, meio-fio, areia). salvador_final é o resort.
    "salvador_1": {"src": "sal_back1", "lines": [567, 704, 724], "targets": CIDADE, "boxes": []},
    "salvador_2": {"src": "sal_back2", "lines": [567, 704, 724], "targets": CIDADE, "boxes": []},
    "salvador_3": {"src": "sal_back3", "lines": [567, 704, 724], "targets": CIDADE, "boxes": []},
    "salvador_final": {"src": "sal_final", "lines": [649, 712, 728], "targets": CIDADE, "boxes": []},
    # Fase 5: Bosque dos Jequitibás (pé da cerca, meio-fio, grama). bosque_final é a jaula.
    "bosque_1": {"src": "j_back1", "lines": [624, 724, 738], "targets": BOSQUE, "boxes": []},
    "bosque_2": {"src": "j_back2", "lines": [590, 734, 742], "targets": BOSQUE, "boxes": []},
    "bosque_3": {"src": "j_back3", "lines": [570, 711, 721], "targets": BOSQUE, "boxes": []},
    "bosque_final": {"src": "j_final", "lines": [601, 729, 743], "targets": BOSQUE, "boxes": []},
}


def feather_box(image, edge_x, side, max_y):
    """Mistura a borda da caixa com o céu liso da faixa lateral."""
    pixels = image.load()
    outside_x = edge_x - 40 if side == "left" else edge_x + 40
    for y in range(max_y):
        sky = pixels[outside_x, y]
        for step in range(FEATHER):
            x = edge_x + step if side == "left" else edge_x - 1 - step
            weight = step / FEATHER
            weight = weight * weight * (3 - 2 * weight)
            scene = pixels[x, y]
            pixels[x, y] = tuple(int(sky[c] + (scene[c] - sky[c]) * weight) for c in range(3))


def remap_bands(image, pairs):
    """Estica/encolhe as faixas entre os pares (linha na imagem, linha na saída)."""
    width = OUT_SIZE[0]
    pairs = [(0, 0)] + list(pairs) + [(WORK_SIZE[1], OUT_SIZE[1])]
    out = Image.new("RGB", OUT_SIZE)
    for (src_top, dst_top), (src_bottom, dst_bottom) in zip(pairs, pairs[1:]):
        part = image.crop((0, src_top, WORK_SIZE[0], src_bottom))
        part = part.resize((width, dst_bottom - dst_top), Image.LANCZOS)
        out.paste(part, (0, dst_top))
    return out


def output_lines(info):
    if "lines" in info:
        return list(zip(info["lines"], info.get("targets", RUA)))
    return [(info["curb"], CURB_Y), (info["grass"], GRASS_Y)]


def main():
    os.makedirs("art", exist_ok=True)
    only = sys.argv[1:]
    for name, info in IMAGES.items():
        if only and name not in only:
            continue
        image = Image.open(f"images/{info['src']}.jpeg").convert("RGB").resize(WORK_SIZE, Image.LANCZOS)
        if "crop" in info:
            image = image.crop((info["crop"][0], 0, info["crop"][1], WORK_SIZE[1])).resize(WORK_SIZE, Image.LANCZOS)
        for edge_x, side, max_y in info["boxes"]:
            feather_box(image, edge_x, side, max_y)
        out = remap_bands(image, output_lines(info))
        out.save(f"art/{name}.jpg", quality=92)
        print(f"images/{info['src']}.jpeg -> art/{name}.jpg {OUT_SIZE[0]}x{OUT_SIZE[1]}")


if __name__ == "__main__":
    main()
