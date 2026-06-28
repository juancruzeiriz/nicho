# Nueva PRIMER imagen del listing (Etsy/Gumroad) que lidera con el moat: el
# coach adaptativo. La portada vieja (01_cover.png) "lee" como plantilla generica;
# esta muestra de entrada lo que ningun competidor generico ofrece.
#   python products/Fitness_Tracker/build_first_image.py
# Salida: mockups/00_first_image.png (1200x1200, formato Etsy).  Pillow puro.
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'mockups')

DARK = (31, 41, 55)
ACCENT = (37, 99, 235)
GREEN = (22, 163, 74)
AMBER = (217, 119, 6)
WHITE = (255, 255, 255)
GREY = (107, 114, 128)
BG = (243, 244, 246)
W = H = 1200


def font(size, bold=False):
    for n in (['arialbd.ttf', 'Arialbd.ttf'] if bold else ['arial.ttf', 'Arial.ttf']):
        try:
            return ImageFont.truetype(n, size)
        except OSError:
            continue
    try:
        return ImageFont.truetype('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf', size)
    except OSError:
        return ImageFont.load_default()


def wrap(d, text, fnt, max_w):
    words, lines, cur = text.split(), [], ''
    for w in words:
        p = (cur + ' ' + w).strip()
        if d.textlength(p, font=fnt) <= max_w:
            cur = p
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def center(d, text, fnt, y, fill, x0=0, w=W):
    tw = d.textlength(text, font=fnt)
    d.text((x0 + (w - tw) / 2, y), text, font=fnt, fill=fill)


def main():
    os.makedirs(OUT, exist_ok=True)
    im = Image.new('RGB', (W, H), BG)
    d = ImageDraw.Draw(im)

    # --- Banda superior ---
    d.rectangle([0, 0, W, 200], fill=DARK)
    center(d, 'ADAPTIVE FITNESS TRACKER', font(56, True), 56, WHITE)
    center(d, 'The spreadsheet that coaches you back', font(32), 132, (180, 190, 205))

    # --- Tarjeta COACH (el heroe) ---
    cx0, cy0, cx1, cy1 = 70, 250, W - 70, 250 + 470
    d.rounded_rectangle([cx0, cy0, cx1, cy1], radius=28, fill=WHITE,
                        outline=ACCENT, width=4)
    # etiqueta
    d.rounded_rectangle([cx0 + 40, cy0 + 36, cx0 + 360, cy0 + 86], radius=14, fill=ACCENT)
    d.text((cx0 + 60, cy0 + 44), 'ADAPTIVE COACH', font=font(30, True), fill=WHITE)
    # mensaje del coach (lo que dice la hoja)
    msg_f = font(52, True)
    msg = "You're losing 0.9%/week - too fast for a cut."
    y = cy0 + 120
    for ln in wrap(d, msg, msg_f, (cx1 - cx0) - 90):
        d.text((cx0 + 45, y), ln, font=msg_f, fill=DARK)
        y += 64
    # accion (verde, la sugerencia adaptativa)
    y += 14
    act_f = font(46, True)
    for ln in wrap(d, '-> Add ~150 kcal to protect muscle', act_f, (cx1 - cx0) - 90):
        d.text((cx0 + 45, y), ln, font=act_f, fill=GREEN)
        y += 56
    # pie de la tarjeta
    d.text((cx0 + 45, cy1 - 70), 'Based on your real 7-day trend - not the daily scale noise.',
           font=font(28), fill=GREY)

    # --- Strip de prueba: screenshot real del dashboard ---
    proof_p = os.path.join(OUT, '03_dashboard.png')
    py = cy1 + 40
    if os.path.exists(proof_p):
        shot = Image.open(proof_p).convert('RGB')
        shot = shot.crop((0, int(shot.height * 0.36), shot.width, shot.height))  # sacar caption band
        scale = (W - 160) / shot.width
        shot = shot.resize((W - 160, int(shot.height * scale)))
        maxh = (H - 120) - py
        if shot.height > maxh:
            shot = shot.crop((0, 0, shot.width, maxh))
        card = Image.new('RGB', (shot.width + 12, shot.height + 12), WHITE)
        card.paste(shot, (6, 6))
        im.paste(card, ((W - card.width) // 2, py))

    # --- Banda inferior ---
    d.rectangle([0, H - 80, W, H], fill=ACCENT)
    center(d, 'Excel + Google Sheets   .   TDEE + Macros   .   RIR Workout Log',
           font(30, True), H - 58, WHITE)

    path = os.path.join(OUT, '00_first_image.png')
    im.save(path)
    print('guardado:', os.path.relpath(path, os.path.dirname(HERE)))


if __name__ == '__main__':
    main()
