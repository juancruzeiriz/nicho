# Genera los mockups del listing de Etsy/Gumroad a partir del render real del
# workbook (sin ImageMagick: LibreOffice -> PDF -> PNG con PyMuPDF, compuesto
# con Pillow). Correr: python build_mockups.py
import os
import subprocess

import fitz
from PIL import Image, ImageDraw, ImageFont

WB = 'Adaptive_Fitness_Tracker.xlsx'
SOFFICE = r"C:\Program Files\LibreOffice\program\soffice.exe"
OUT = 'mockups'
os.makedirs(OUT, exist_ok=True)

DARK = (31, 41, 55)
ACCENT = (37, 99, 235)
GREEN = (22, 163, 74)
WHITE = (255, 255, 255)
GREY = (107, 114, 128)
BG = (243, 244, 246)


def font(size, bold=False):
    names = (['arialbd.ttf', 'Arialbd.ttf'] if bold else ['arial.ttf', 'Arial.ttf'])
    for n in names:
        try:
            return ImageFont.truetype(n, size)
        except OSError:
            continue
    return ImageFont.load_default()


def render_pages():
    subprocess.run([SOFFICE, '--headless', '--calc', '--convert-to', 'pdf',
                    '--outdir', '.', WB], capture_output=True, timeout=120)
    doc = fitz.open('Adaptive_Fitness_Tracker.pdf')
    pages = {}
    for idx, key in ((0, 'dashboard'), (1, 'setup'), (5, 'workout')):
        pix = doc[idx].get_pixmap(dpi=170)
        p = os.path.join(OUT, f'_page_{key}.png')
        pix.save(p)
        pages[key] = p
    doc.close()
    return pages


def crop_top(path, frac):
    im = Image.open(path).convert('RGB')
    return im.crop((0, 0, im.width, int(im.height * frac)))


def center(draw, text, fnt, y, w, fill, x0=0):
    bb = draw.textbbox((0, 0), text, font=fnt)
    draw.text((x0 + (w - (bb[2] - bb[0])) / 2, y), text, font=fnt, fill=fill)


# Mockup 1 — Portada (1200x1200, formato Etsy)
def cover(pages):
    W = H = 1200
    im = Image.new('RGB', (W, H), BG)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, W, 250], fill=DARK)
    center(d, 'ADAPTIVE FITNESS TRACKER', font(62, True), 70, W, WHITE)
    center(d, 'The spreadsheet that coaches you back', font(34), 160, W, (180, 190, 205))
    dash = crop_top(pages['dashboard'], 0.42)
    scale = (W - 120) / dash.width
    dash = dash.resize((W - 120, int(dash.height * scale)))
    card = Image.new('RGB', (dash.width + 16, dash.height + 16), WHITE)
    card.paste(dash, (8, 8))
    im.paste(card, (52, 300))
    y = 300 + card.height + 50
    feats = ['TDEE + macro calculator', '7-day weight trend engine',
             'Adaptive coach suggestions', 'RIR workout log with auto-PRs']
    for f in feats:
        d.ellipse([90, y + 10, 110, y + 30], fill=GREEN)
        d.text((130, y), f, font=font(38, True), fill=DARK)
        y += 64
    d.rectangle([0, H - 70, W, H], fill=ACCENT)
    center(d, 'Excel  +  Google Sheets   •   Metric & Imperial', font(30, True), H - 54, W, WHITE)
    im.save(os.path.join(OUT, '01_cover.png'))


# Mockup generico — caption arriba + screenshot
def feature(pages, key, frac, fname, title, sub):
    W = 1200
    shot = crop_top(pages[key], frac)
    scale = (W - 100) / shot.width
    shot = shot.resize((W - 100, int(shot.height * scale)))
    H = 230 + shot.height + 50
    im = Image.new('RGB', (W, H), BG)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, W, 200], fill=DARK)
    center(d, title, font(52, True), 50, W, WHITE)
    center(d, sub, font(30), 130, W, (180, 190, 205))
    card = Image.new('RGB', (shot.width + 16, shot.height + 16), WHITE)
    card.paste(shot, (8, 8))
    im.paste(card, (42, 230))
    im.save(os.path.join(OUT, fname))


pages = render_pages()
cover(pages)
feature(pages, 'setup', 0.55, '02_setup.png',
        'Fill in 8 cells. Get your numbers.',
        'TDEE, macros and protein targets — Metric or Imperial')
feature(pages, 'dashboard', 0.42, '03_dashboard.png',
        'Your whole plan on one screen',
        'Targets, real weight trend, coach suggestion and live chart')
feature(pages, 'workout', 0.30, '04_workout.png',
        'Track strength, not soreness',
        'RIR logging with automatic estimated 1RM and PR flags')
print('mockups en', OUT)
for f in sorted(os.listdir(OUT)):
    if not f.startswith('_'):
        print('  ', f)
