# Arma el ZIP del comprador para Real Guitar Stream Alerts (Vol. 1).
# Cross-platform (no depende de PowerShell). Correr desde esta carpeta:
#   python build_sfx_pack.py                 # tier standard (MP3)
#   python build_sfx_pack.py --tier commercial
#   python build_sfx_pack.py --wav-dir ..\..\audios_wav
import argparse
import os
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
AUDIO_DIR = os.path.normpath(os.path.join(HERE, '..', '..', 'audios'))

# Mapa origen (audios/) -> nombre de venta. Agregar acá los sonidos nuevos (Vol. 2).
RENAMES = {
    'alert-clean-1.mp3': 'RGSP_Clean_Alert_01.mp3',
    'alert-clean-2.mp3': 'RGSP_Clean_Alert_02.mp3',
    'alert-overdrive-1.mp3': 'RGSP_Overdrive_Alert_01.mp3',
    'alert-overdrive-2.mp3': 'RGSP_Overdrive_Alert_02.mp3',
    'alert-fuzz-1.mp3': 'RGSP_Fuzz_Alert_01.mp3',
    'alert-fuzz-2.mp3': 'RGSP_Fuzz_Alert_02.mp3',
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tier', choices=['standard', 'commercial'], default='standard')
    ap.add_argument('--audio-dir', default=AUDIO_DIR)
    ap.add_argument('--wav-dir', default='')
    args = ap.parse_args()

    # Guardas: todos los origenes y archivos de soporte tienen que existir
    missing = [s for s in RENAMES if not os.path.exists(os.path.join(args.audio_dir, s))]
    for f in ('README_BUYER_EN.txt', 'LICENSE_Standard.txt', 'LICENSE_Commercial.txt'):
        if not os.path.exists(os.path.join(HERE, f)):
            missing.append(f)
    if missing:
        print('ERROR: faltan archivos, no se arma el ZIP:')
        for m in missing:
            print('  -', m)
        sys.exit(1)

    lic = 'LICENSE_Commercial.txt' if args.tier == 'commercial' else 'LICENSE_Standard.txt'
    out = os.path.join(HERE, f'RealGuitar_StreamAlerts_{args.tier}.zip')
    if os.path.exists(out):
        os.remove(out)

    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        for src, dst in RENAMES.items():
            z.write(os.path.join(args.audio_dir, src), f'01_Alerts_MP3/{dst}')
        if args.wav_dir and os.path.isdir(args.wav_dir):
            for w in sorted(os.listdir(args.wav_dir)):
                if w.lower().endswith('.wav'):
                    z.write(os.path.join(args.wav_dir, w), f'02_Alerts_WAV/{w}')
        z.write(os.path.join(HERE, 'README_BUYER_EN.txt'), 'README.txt')
        z.write(os.path.join(HERE, lic), 'LICENSE.txt')

    kb = os.path.getsize(out) // 1024
    print(f'ZIP listo: {os.path.basename(out)}  ({kb} KB)')
    with zipfile.ZipFile(out) as z:
        for n in z.namelist():
            print('  -', n)


if __name__ == '__main__':
    main()
