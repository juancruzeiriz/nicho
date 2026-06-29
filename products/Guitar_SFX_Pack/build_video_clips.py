# Fabrica de clips verticales (9:16) para TikTok / YouTube Shorts / Reels a
# partir de los MP3 del pack. NO requiere filmar nada: el audio real es la
# estrella y FFmpeg dibuja la onda animada encima de un fondo con texto.
#
#   python products/Guitar_SFX_Pack/build_video_clips.py
#
# Como funciona (robusto a proposito):
#   1) Pillow hornea un fondo 1080x1920 por clip (caption + branding + CTA),
#      dejando un hueco en el centro para la onda. Esto corre en cualquier lado
#      y se puede verificar leyendo los PNG.
#   2) FFmpeg superpone showwaves (onda animada) + el audio -> MP4 vertical.
#      Si ffmpeg no esta en el PATH, el script igual deja los fondos PNG y
#      imprime el comando exacto para que lo corras vos en Windows.
#
# Pensado para correrse desde la raiz del repo (lee de ./audios).
import os
import shutil
import subprocess

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
AUDIO_DIR = os.path.join(ROOT, 'audios')
OUT = os.path.join(ROOT, 'products', 'Guitar_SFX_Pack', 'video_clips')
BG_DIR = os.path.join(OUT, '_bg')

W, H = 1080, 1920
# Hueco donde FFmpeg dibuja la onda (debe coincidir con el comando de abajo)
WAVE_X, WAVE_Y, WAVE_W, WAVE_H = 40, 800, 1000, 380

DARK = (18, 18, 20)
AMBER = (245, 158, 11)
RED = (220, 38, 38)
WHITE = (245, 245, 245)
GREY = (155, 155, 163)

# Cada clip: archivo de audio -> tono, evento y caption (hook del video).
CLIPS = [
    ('alert-fuzz-1.mp3', 'FUZZ', 'raid alert', RED,
     'POV: your raid alert is a real guitar, not a synth preset.'),
    ('alert-overdrive-1.mp3', 'OVERDRIVE', 'donation alert', AMBER,
     'This is what a donation alert should sound like.'),
    ('alert-clean-1.mp3', 'CLEAN', 'new-follower alert', (250, 204, 21),
     'Your new-follower sound could be a real guitar.'),
    ('alert-fuzz-2.mp3', 'FUZZ', 'hype-train alert', RED,
     'Three tones, played on a real rig. This is the fuzz one.'),
    ('alert-overdrive-2.mp3', 'OVERDRIVE', 'big-donation alert', AMBER,
     'Real strings. Real pedals. Zero presets.'),
    ('alert-clean-2.mp3', 'CLEAN', 'new-sub alert', (250, 204, 21),
     'Tired of alerts that sound like a toy keyboard?'),
]


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


def wrap(d, text, fnt, max_w):
    words, lines, cur = text.split(), [], ''
    for w in words:
        probe = (cur + ' ' + w).strip()
        if d.textlength(probe, font=fnt) <= max_w:
            cur = probe
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def center(d, text, fnt, y, fill):
    w = d.textlength(text, font=fnt)
    d.text(((W - w) / 2, y), text, font=fnt, fill=fill)


def build_bg(tone, event, accent, caption, path):
    im = Image.new('RGB', (W, H), DARK)
    d = ImageDraw.Draw(im)
    # glow superior sutil
    for i in range(220):
        a = int(40 * (1 - i / 220))
        d.line([(0, i), (W, i)], fill=(18 + a // 2, 18 + a // 4, 22))
    # caption (hook) arriba
    cap_f = font(74, True)
    lines = wrap(d, caption, cap_f, W - 140)
    y = 230
    for ln in lines:
        center(d, ln, cap_f, y, WHITE)
        y += 92
    # regla amber bajo el caption
    d.rectangle([W / 2 - 90, y + 24, W / 2 + 90, y + 32], fill=accent)
    # (el hueco WAVE_* queda en el centro para FFmpeg)
    # tono + evento debajo de la onda
    yb = WAVE_Y + WAVE_H + 70
    center(d, tone, font(120, True), yb, accent)
    center(d, event.upper(), font(46, True), yb + 140, GREY)
    # branding + CTA abajo
    center(d, 'REAL GUITAR STREAM ALERTS  -  Vol. 1', font(40, True), H - 250, WHITE)
    center(d, 'Pay what you want  .  riffstream.itch.io', font(44, True), H - 170, accent)
    im.save(path)


def ffmpeg_cmd(bg, audio, out, accent):
    hexcol = '0x%02X%02X%02X' % accent
    # showwaves dibuja la onda sobre fondo NEGRO opaco -> con colorkey lo volvemos
    # transparente para que en el overlay quede SOLO la onda de color sobre el fondo.
    flt = (
        f"[1:a]showwaves=s={WAVE_W}x{WAVE_H}:mode=cline:colors={hexcol}:rate=30,"
        f"format=rgba,colorkey=0x000000:0.10:0.06[w];"
        f"[0:v][w]overlay={WAVE_X}:{WAVE_Y}:format=auto:shortest=1[v]"
    )
    return [
        'ffmpeg', '-y', '-loop', '1', '-i', bg, '-i', audio,
        '-filter_complex', flt, '-map', '[v]', '-map', '1:a',
        '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-r', '30',
        '-c:a', 'aac', '-b:a', '192k', '-shortest', out,
    ]


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(BG_DIR, exist_ok=True)
    have_ffmpeg = shutil.which('ffmpeg') is not None
    if not have_ffmpeg:
        print('AVISO: ffmpeg no esta en el PATH. Genero los fondos PNG igual y')
        print('       dejo los comandos para que corras los MP4 en Windows.\n')
    def rel(p):  # path relativo a ROOT, con / (sirve para ffmpeg y bash en Win)
        return os.path.relpath(p, ROOT).replace('\\', '/')

    cmds = []
    for audio_name, tone, event, accent, caption in CLIPS:
        audio = os.path.join(AUDIO_DIR, audio_name)
        if not os.path.exists(audio):
            print('  FALTA audio:', audio)
            continue
        stem = os.path.splitext(audio_name)[0]
        bg = os.path.join(BG_DIR, stem + '.png')
        out = os.path.join(OUT, stem + '.mp4')
        build_bg(tone, event, accent, caption, bg)
        cmd = ffmpeg_cmd(rel(bg), rel(audio), rel(out), accent)
        cmds.append(cmd)
        print('  fondo:', rel(bg))
        if have_ffmpeg:
            r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
            if r.returncode == 0:
                print('   ->  MP4:', rel(out))
            else:
                print('   ERROR ffmpeg:', r.stderr.strip().splitlines()[-1:])
    if not have_ffmpeg:
        sh = os.path.join(OUT, 'render_clips.sh')
        with open(sh, 'w', encoding='utf-8', newline='\n') as f:
            # se ubica solo en la raiz del repo, sin importar desde donde se corra
            f.write('#!/usr/bin/env bash\nset -e\ncd "$(dirname "$0")/../../.."\n')
            for c in cmds:
                f.write(' '.join('"%s"' % a if (' ' in a or a.startswith('[')) else a
                                 for a in c) + '\n')
        print('\nComandos guardados en', rel(sh))
        print('Corre en Windows (con ffmpeg en el PATH):  bash', rel(sh))
    print('listo.')


if __name__ == '__main__':
    main()
