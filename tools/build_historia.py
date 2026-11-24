"""Prepara as imagens da história de abertura (images/H_1.jpeg ... H_N.jpeg).

Cada imagem original tem uma moldura branca com cantos arredondados: o script
corta a moldura (mais uma folga para sumir com os cantos) e grava:

  art/historia_N.jpg         a cena, 1400 px de largura, mantendo a proporção
  art/historia_N_fundo.jpg   a mesma cena pequena, desfocada e escura (fundo da tela)

Uso: python3 tools/build_historia.py
"""

from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "images"
OUTPUT = ROOT / "art"
WIDTH = 1400
# Além da moldura, corta esta folga para tirar os cantos arredondados.
CORNER_MARGIN = 32
WHITE = 235


def content_box(image: Image.Image) -> tuple[int, int, int, int]:
    """Limites da ilustração dentro da moldura branca (medidos no meio da imagem)."""
    gray = image.convert("L")
    width, height = gray.size
    row = [gray.getpixel((x, height // 2)) for x in range(width)]
    column = [gray.getpixel((width // 2, y)) for y in range(height)]

    def first_dark(values):
        return next(i for i, value in enumerate(values) if value < WHITE)

    left = first_dark(row)
    right = width - first_dark(row[::-1])
    top = first_dark(column)
    bottom = height - first_dark(column[::-1])
    return (left + CORNER_MARGIN, top + CORNER_MARGIN, right - CORNER_MARGIN, bottom - CORNER_MARGIN)


def main() -> None:
    sources = sorted(SOURCE.glob("H_*.jpeg"), key=lambda path: int(path.stem.split("_")[1]))
    for path in sources:
        number = int(path.stem.split("_")[1])
        image = Image.open(path).convert("RGB")
        scene = image.crop(content_box(image))
        height = round(WIDTH * scene.height / scene.width)
        scene.resize((WIDTH, height), Image.LANCZOS).save(OUTPUT / f"historia_{number}.jpg", quality=90)

        backdrop = scene.resize((480, 270), Image.LANCZOS).filter(ImageFilter.GaussianBlur(10))
        backdrop = ImageEnhance.Brightness(backdrop).enhance(0.55)
        backdrop.save(OUTPUT / f"historia_{number}_fundo.jpg", quality=85)
        print(f"{path.name} -> historia_{number}.jpg ({WIDTH}x{height})")


if __name__ == "__main__":
    main()
