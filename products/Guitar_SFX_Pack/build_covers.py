# Genera el cover art del pack SFX (sin ImageMagick: Pillow puro).
#   python build_covers.py
# Salidas en cover/: itch_cover.png (630x500), cover_wide.png (1600x900),
# thumb.png (1200x1200).
import math
import os

from PIL import Image, ImageDraw, ImageFont

OUT = 'cover'
os.makedirs(OUT, exist_ok=True)

DARK = (18, 18, 20)
PANEL = (28, 28, 32)
AMBER = (245, 158, 11)
RED = (220, 38, 38)
WHITE = (245, 245, 245)
GREY = (150, 150, 158)


def font(size, bold=True):
    for n in (['arialbd.ttf', 'Arialbd.ttf'] if bold else ['arial.ttf']):
        try:
            return ImageFont.truetype(n, size)
        except OSError:
            continue
    return ImageFont.load_default()


def waveform(d, x0, y0, w, h, color, seed=1, amp=1.0):
    """Dibuja una forma de onda estilizada."""
    import random
    random.seed(seed)
    mid = y0 + h / 2
    n = 90
    bw = w / n
    for i in range(n):
        env = math.sin(i / n * math.pi)  # sobre la barra
        a = (0.25 + 0.75 * random.random()) * env * amp
        bh = a * h / 2
        x = x0 + i * bw
        d.rectangle([x, mid - bh, x + bw * 0.6, mid + bh], fill=color)


def center(d, text, fnt, cx, y, fill):
    bb = d.textbbox((0, 0), text, font=fnt)
    d.text((cx - (bb[2] - bb[0]) / 2, y), text, font=fnt, fill=fill)


def make(W, H, name, title_size, sub=True):
    im = Image.new('RGB', (W, H), DARK)
    d = ImageDraw.Draw(im)
    # glow superior
    for i in range(140):
        a = int(36 * (1 - i / 140))
        d.line([(0, i), (W, i)], fill=(18 + a // 3, 18 + a // 6, 22))
    cx = W // 2
    # waveform central (3 tonos: clean amber-ish, od amber, fuzz red)
    wy = int(H * 0.40)
    wh = int(H * 0.22)
    waveform(d, int(W * 0.08), wy, int(W * 0.84), wh, AMBER, seed=3, amp=1.0)
    waveform(d, int(W * 0.08), wy, int(W * 0.84), int(wh * 0.55), RED, seed=7, amp=0.6)
    # titulo
    center(d, 'REAL GUITAR', font(title_size), cx, int(H * 0.10), WHITE)
    center(d, 'STREAM ALERTS', font(title_size), cx, int(H * 0.10) + int(title_size * 1.05), AMBER)
    if sub:
        center(d, 'Boutique tone SFX  ·  Vol. 1', font(int(title_size * 0.42), bold=False),
               cx, int(H * 0.66), GREY)
        center(d, 'CLEAN   ·   OVERDRIVE   ·   FUZZ', font(int(title_size * 0.36)),
               cx, int(H * 0.74), WHITE)
        center(d, 'Real strings. Real pedals. Zero presets.',
               font(int(title_size * 0.34), bold=False), cx, int(H * 0.86), AMBER)
    im.save(os.path.join(OUT, name))
    print('  ', name, im.size)


# Wide (Gumroad/Etsy)
make(1600, 900, 'cover_wide.png', 120)
# itch.io cover
make(630, 500, 'itch_cover.png', 52)
# Thumbnail cuadrado
make(1200, 1200, 'thumb.png', 96)
print('covers en', OUT)
