# Genera banners de redes en el tamano correcto, reusando icono.png como logo.
#   python branding/build_social_banners.py
# Salidas en branding/: yt_banner_2560x1440.png, reddit_banner_1920x384.png
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LOGO = os.path.join(ROOT, 'icono.png')

DARK = (16, 16, 18)
RED = (220, 38, 38)
WHITE = (245, 245, 245)
GREY = (165, 165, 173)


def font(size, bold=True):
    for n in (['arialbd.ttf', 'Arialbd.ttf'] if bold else ['arial.ttf', 'Arial.ttf']):
        try:
            return ImageFont.truetype(n, size)
        except OSError:
            continue
    try:
        return ImageFont.truetype('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf', size)
    except OSError:
        return ImageFont.load_default()


def bg(W, H):
    im = Image.new('RGB', (W, H), DARK)
    d = ImageDraw.Draw(im)
    # glow rojo en los bordes laterales
    for x in range(220):
        a = int(60 * (1 - x / 220))
        d.line([(x, 0), (x, H)], fill=(16 + a, 16 + a // 5, 18 + a // 5))
        d.line([(W - 1 - x, 0), (W - 1 - x, H)], fill=(16 + a, 16 + a // 5, 18 + a // 5))
    return im


def make(W, H, out, logo_h, title_sz, sub_sz, safe_w=None, sub=True):
    im = bg(W, H)
    d = ImageDraw.Draw(im)
    logo = Image.open(LOGO).convert('RGB')
    s = logo_h / logo.height
    logo = logo.resize((int(logo.width * s), logo_h))
    title_f, sub_f, tiny_f = font(title_sz), font(sub_sz, False), font(int(sub_sz * 0.8), False)
    title = 'RiffStream'
    subt = 'Real guitar stream SFX  +  smart fitness tools'
    tiny = 'itch  -  Gumroad  -  Etsy'
    tw = max(d.textlength(title, font=title_f),
             d.textlength(subt, font=sub_f) if sub else 0)
    gap = 48
    block_w = logo.width + gap + int(tw)
    x0 = (W - block_w) // 2
    ly = (H - logo.height) // 2
    im.paste(logo, (x0, ly))
    tx = x0 + logo.width + gap
    if sub:
        ty = H // 2 - title_sz
        d.text((tx, ty), title, font=title_f, fill=WHITE)
        d.text((tx, ty + int(title_sz * 1.05)), subt, font=sub_f, fill=GREY)
        d.text((tx, ty + int(title_sz * 1.05) + int(sub_sz * 1.5)), tiny, font=tiny_f, fill=RED)
    else:
        d.text((tx, (H - title_sz) // 2), title, font=title_f, fill=WHITE)
    im.save(out)
    print('  ', os.path.relpath(out, ROOT), im.size)


# YouTube: 2560x1440, contenido en la zona segura central (1546x423)
make(2560, 1440, os.path.join(HERE, 'yt_banner_2560x1440.png'),
     logo_h=300, title_sz=150, sub_sz=52)
# Reddit: banner ancho y bajo
make(1920, 384, os.path.join(HERE, 'reddit_banner_1920x384.png'),
     logo_h=300, title_sz=110, sub_sz=40)
print('listo.')
