#!/usr/bin/env python3
"""Converte os GIFs de animação em folhas de sprites PNG para o Godot.

Uso:
    python3 tools/gif_to_sheet.py                       # converte images/*.gif -> art/*.png
    python3 tools/gif_to_sheet.py images/x.gif art/x.png

Cada quadro do GIF vira uma célula, lado a lado, numa única linha.
Se o GIF tiver fundo de cor sólida (ex.: cinza), essa cor é removida
e vira transparente. O número de quadros e a duração são impressos no
terminal para registrar no main.gd.

Requer Pillow (python3-pil).
"""
import glob
import os
import sys

from PIL import Image, ImageSequence

BACKGROUND_TOLERANCE = 10


def _close(a, b, tol):
    return all(abs(int(x) - int(y)) <= tol for x, y in zip(a[:3], b[:3]))


# Áreas da cor do fundo menores que isto e fechadas pelo personagem são
# mantidas (ex.: a íris cinza dos olhos). Áreas maiores (vão entre braço e
# corpo) são removidas.
MIN_ENCLOSED_AREA = 60


def remove_solid_background(frame: Image.Image) -> Image.Image:
    """Torna transparente a cor de fundo, se o canto do quadro for opaco.

    Remove as regiões da cor do fundo que tocam a borda e as regiões
    fechadas grandes; preserva detalhes pequenos da mesma cor.
    """
    corner = frame.getpixel((0, 0))
    if corner[3] == 0:
        return frame
    pixels = frame.load()
    width, height = frame.size
    seen = bytearray(width * height)
    for start_y in range(height):
        for start_x in range(width):
            if seen[start_y * width + start_x] or not _close(pixels[start_x, start_y], corner, BACKGROUND_TOLERANCE):
                continue
            region = []
            touches_border = False
            stack = [(start_x, start_y)]
            seen[start_y * width + start_x] = 1
            while stack:
                x, y = stack.pop()
                region.append((x, y))
                if x == 0 or y == 0 or x == width - 1 or y == height - 1:
                    touches_border = True
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < width and 0 <= ny < height and not seen[ny * width + nx] \
                            and _close(pixels[nx, ny], corner, BACKGROUND_TOLERANCE):
                        seen[ny * width + nx] = 1
                        stack.append((nx, ny))
            if touches_border or len(region) >= MIN_ENCLOSED_AREA:
                for x, y in region:
                    pixels[x, y] = (0, 0, 0, 0)
    return frame


def convert(gif_path: str, png_path: str) -> None:
    gif = Image.open(gif_path)
    frames = []
    durations = []
    for frame in ImageSequence.Iterator(gif):
        durations.append(frame.info.get("duration", 100))
        frames.append(remove_solid_background(frame.convert("RGBA")))
    cell_w, cell_h = frames[0].size
    sheet = Image.new("RGBA", (cell_w * len(frames), cell_h), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * cell_w, 0))
    os.makedirs(os.path.dirname(png_path) or ".", exist_ok=True)
    sheet.save(png_path)
    print(f"{gif_path} -> {png_path}: {len(frames)} quadros de {cell_w}x{cell_h}, "
          f"{durations[0]} ms por quadro")


def main() -> None:
    if len(sys.argv) == 3:
        convert(sys.argv[1], sys.argv[2])
        return
    for gif_path in sorted(glob.glob("images/*.gif")):
        name = os.path.splitext(os.path.basename(gif_path))[0].lower()
        convert(gif_path, os.path.join("art", name + ".png"))


if __name__ == "__main__":
    main()
