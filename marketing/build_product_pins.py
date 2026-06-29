# Fabrica de pines de Pinterest para los dos productos foco.
#   python marketing/build_product_pins.py        (correr desde la raiz del repo)
#
# Genera variantes 1000x1500 (ratio 2:3, el optimo de Pinterest) combinando un
# hero real del producto + distintos hooks de copy. Sin ImageMagick: Pillow puro.
# Salidas en products/<Producto>/pins/.
#
# Editar la lista PINS de abajo para agregar/cambiar hooks. Cada hook = un pin.
import os
import textwrap as _tw

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

W, H = 1000, 1500
MARGIN = 60

# ---- Paletas por producto -------------------------------------------------
FITNESS = dict(
    bg=(243, 244, 246), band=(31, 41, 55), accent=(37, 99, 235),
    hook=(255, 255, 255), sub=(186, 196, 210), cta=(255, 255, 255),
    card_border=(255, 255, 255),
)
SFX = dict(
    bg=(18, 18, 20), band=(24, 24, 28), accent=(245, 158, 11),
    hook=(245, 245, 245), sub=(160, 160, 168), cta=(18, 18, 20),
    card_border=(245, 158, 11),
)


def font(size, bold=True):
    names = (['arialbd.ttf', 'Arialbd.ttf'] if bold else ['arial.ttf', 'Arial.ttf'])
    for n in names:
        try:
            return ImageFont.truetype(n, size)
        except OSError:
            continue
    # Fallback que Pillow trae siempre, para no romper el render.
    try:
        return ImageFont.truetype('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf', size)
    except OSError:
        return ImageFont.load_default()


def wrap(draw, text, fnt, max_w):
    """Parte el texto en lineas que entran en max_w pixeles."""
    words = text.split()
    lines, cur = [], ''
    for w in words:
        probe = (cur + ' ' + w).strip()
        if draw.textlength(probe, font=fnt) <= max_w:
            cur = probe
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def draw_block(draw, lines, fnt, y, fill, line_h, max_w):
    for ln in lines:
        w = draw.textlength(ln, font=fnt)
        draw.text(((W - w) / 2, y), ln, font=fnt, fill=fill)
        y += line_h
    return y


def fit(im, max_w, max_h):
    s = min(max_w / im.width, max_h / im.height)
    return im.resize((int(im.width * s), int(im.height * s)))


def load_hero(spec):
    im = Image.open(os.path.join(ROOT, spec['src'])).convert('RGB')
    if 'crop' in spec:  # (top_frac, bottom_frac)
        t, b = spec['crop']
        im = im.crop((0, int(im.height * t), im.width, int(im.height * b)))
    return im


def build_pin(out_path, hero_im, hook, sub, pal, bullets=None):
    im = Image.new('RGB', (W, H), pal['bg'])
    d = ImageDraw.Draw(im)

    # --- Banda superior con el hook + sub (alto dinamico) ---
    hook_f, sub_f = font(60, True), font(32, False)
    hook_lines = wrap(d, hook, hook_f, W - 2 * MARGIN)
    sub_lines = wrap(d, sub, sub_f, W - 2 * MARGIN)
    hook_lh, sub_lh = 70, 42
    band_h = 60 + len(hook_lines) * hook_lh + 24 + len(sub_lines) * sub_lh + 50
    band_h = max(band_h, 350)
    d.rectangle([0, 0, W, band_h], fill=pal['band'])
    y = 60
    y = draw_block(d, hook_lines, hook_f, y, pal['hook'], hook_lh, W - 2 * MARGIN)
    y += 24
    draw_block(d, sub_lines, sub_f, y, pal['sub'], sub_lh, W - 2 * MARGIN)

    # --- Banda inferior (CTA) ---
    cta_h = 150
    d.rectangle([0, H - cta_h, W, H], fill=pal['accent'])

    region_top = band_h + 50
    region_bot = H - cta_h - 50

    # Reservar espacio para bullets si los hay
    bullet_f = font(38, True)
    bullet_lh = 86
    bullets_h = (len(bullets) * bullet_lh + 30) if bullets else 0
    hero_max_h = (region_bot - region_top) - bullets_h

    # --- Hero dentro de una tarjeta ---
    hero = fit(hero_im, W - 2 * MARGIN, hero_max_h)
    bw = 10  # borde de la tarjeta
    card = Image.new('RGB', (hero.width + 2 * bw, hero.height + 2 * bw), pal['card_border'])
    card.paste(hero, (bw, bw))
    cx = (W - card.width) // 2
    block_h = card.height + bullets_h
    cy = region_top + (region_bot - region_top - block_h) // 2
    d.rectangle([cx + 8, cy + 10, cx + card.width + 8, cy + card.height + 10],
                fill=tuple(max(0, c - 18) for c in pal['bg']))
    im.paste(card, (cx, cy))

    # --- Bullets debajo del hero ---
    if bullets:
        text_color = pal['band'] if pal['bg'][0] > 128 else pal['hook']
        widths = [d.textlength(b, font=bullet_f) + 56 for b in bullets]
        bx = (W - max(widths)) / 2
        by = cy + card.height + 40
        for b in bullets:
            d.ellipse([bx, by + 12, bx + 26, by + 38], fill=pal['accent'])
            d.text((bx + 46, by), b, font=bullet_f, fill=text_color)
            by += bullet_lh
    return im, cta_h


def render(spec):
    pal = spec['pal']
    hero_im = load_hero(spec)
    outdir = os.path.join(ROOT, spec['outdir'])
    os.makedirs(outdir, exist_ok=True)
    for i, (hook, sub) in enumerate(spec['hooks'], 1):
        im, cta_h = build_pin(None, hero_im, hook, sub, pal, spec.get('bullets'))
        d = ImageDraw.Draw(im)
        cta_f = font(30, True)
        w = d.textlength(spec['cta'], font=cta_f)
        d.text(((W - w) / 2, H - cta_h + (cta_h - 38) / 2), spec['cta'], font=cta_f, fill=pal['cta'])
        name = f"{spec['prefix']}_{i:02d}.png"
        im.save(os.path.join(outdir, name))
        print('  ', os.path.relpath(os.path.join(outdir, name), ROOT))


FIT_LINK = 'https://jeiriz.gumroad.com/l/cajakq'
SFX_LINK = 'https://riffstream.itch.io/real-guitar-stream-alerts-boutique-tone-sfx-vol-1'
FIT_BOARD = 'Fitness & Nutrition'
SFX_BOARD = 'Stream Setup / Twitch'

PINS = [
    # --- Fitness A: hero = dashboard (corto y ancho -> lleva bullets) ---
    dict(
        prefix='pin_fitness', pal=FITNESS,
        src='products/Fitness_Tracker/mockups/03_dashboard.png', crop=(0.36, 1.0),
        outdir='products/Fitness_Tracker/pins',
        cta='Excel + Google Sheets   .   jeiriz.gumroad.com',
        link=FIT_LINK, board=FIT_BOARD,
        bullets=[
            'TDEE + macro calculator',
            '7-day weight-trend engine',
            'Adaptive coach suggestions',
            'RIR workout log with auto-PRs',
        ],
        hooks=[
            ("Your scale is lying to you.",
             "Daily weight swings 1-2% from water. This spreadsheet reads your 7-day "
             "trend and tells you when to cut, hold or add calories back."),
            ("A spreadsheet that coaches you back",
             "TDEE + macros, weight-trend engine and an RIR workout log that flags PRs "
             "- all wired together so it tells you what to do next."),
            ("Most fitness templates just store numbers. This one thinks.",
             "Built by a lifter who codes. Cut, maintain or bulk. Metric & Imperial."),
            ("TDEE Macro Calculator + Weight Trend Tracker",
             "Fill in 8 cells, get your calories and macros, then let it coach you off "
             "your real weekly trend. Excel + Google Sheets."),
            ("Stop quitting your diet over water weight.",
             "A 7-day moving average filters the daily noise so you see your real "
             "direction - and the coach tells you what to change."),
        ],
    ),
    # --- Fitness B: hero = workout log (alto -> sin bullets) ---
    dict(
        prefix='pin_fit_log', pal=FITNESS,
        src='products/Fitness_Tracker/mockups/04_workout.png', crop=(0.325, 1.0),
        outdir='products/Fitness_Tracker/pins',
        cta='RIR log + auto 1RM   .   jeiriz.gumroad.com',
        link=FIT_LINK, board=FIT_BOARD,
        hooks=[
            ("Track strength, not soreness.",
             "Log your sets with RIR; the sheet converts each to an estimated 1RM "
             "(Epley) and flags new PRs automatically."),
            ("Is your cut actually working?",
             "Strength holding while the scale drops = you're keeping muscle. The "
             "workout log shows it set by set."),
            ("Progressive overload, done for you.",
             "RIR-based logging with automatic e1RM and PR flags. Excel + Google "
             "Sheets, metric & imperial."),
        ],
    ),
    # --- Fitness C: hero = setup/calculator ---
    dict(
        prefix='pin_fit_calc', pal=FITNESS,
        src='products/Fitness_Tracker/mockups/02_setup.png', crop=(0.217, 1.0),
        outdir='products/Fitness_Tracker/pins',
        cta='TDEE + macros in 8 cells   .   jeiriz.gumroad.com',
        link=FIT_LINK, board=FIT_BOARD,
        hooks=[
            ("Fill in 8 cells. Get your macros.",
             "TDEE, calories, protein, fat and carbs - Mifflin-St Jeor, 5 activity "
             "levels, cut/maintain/bulk presets. Metric or Imperial."),
            ("Stop guessing your calories.",
             "A real TDEE + macro calculator wired into a weight-trend tracker and a "
             "workout log. Built by a lifter who codes."),
        ],
    ),
    # --- SFX: hero = waveform art ---
    dict(
        prefix='pin_sfx', pal=SFX,
        src='products/Guitar_SFX_Pack/cover/thumb.png',
        outdir='products/Guitar_SFX_Pack/pins',
        cta='Pay what you want   .   riffstream.itch.io',
        link=SFX_LINK, board=SFX_BOARD,
        hooks=[
            ("Your stream alerts sound like a toy keyboard.",
             "Mine sound like a real guitar - through a boutique overdrive and a "
             "germanium fuzz. 6 riffs for follows, donations and raids."),
            ("Real guitar stream alerts (not synth presets)",
             "Clean for follows, crunch for donos, fuzz for raids. Works with "
             "Streamlabs, StreamElements and OBS."),
            ("3 tones for 3 stream moments",
             "Clean . Overdrive . Fuzz - played on a real rig. Zero presets, zero "
             "stock-audio farm. Made by a guitarist who streams."),
            ("Make your raid feel epic.",
             "A real-guitar fuzz riff for the moment your stream gets raided. "
             "Hand-played, not a sample. Pay what you want on itch."),
            ("The tone you can't fake with presets.",
             "Boutique Artemis overdrive + germanium fuzz. If your stream has any "
             "rock, metal or punk in it, these alerts fit."),
            ("Stop using the same alert as everyone else.",
             "6 stream alert riffs on a real electric guitar. Follows, donations, "
             "raids. MP3, normalized, Streamlabs & OBS ready."),
            ("From a guitarist who streams.",
             "Every take played, picked and mixed by hand - not a stock-audio farm. "
             "Real strings, real pedals, zero presets."),
            ("Your raid alert, but it's an actual guitar.",
             "Full-chaos fuzz for raids and hype trains. Clean and overdrive too. "
             "Vol. 1, pay what you want."),
        ],
    ),
]


if __name__ == '__main__':
    for spec in PINS:
        print(spec['prefix'], '->')
        render(spec)
    print('listo.')
