# Genera pinterest_bulk.csv para la carga MASIVA de pines en Pinterest
# (Crear > en lote / bulk upload). Lee la misma config de build_product_pins.py
# para no duplicar texto.
#   python marketing/build_pinterest_csv.py
#
# OJO con "Media URL": Pinterest descarga la imagen de una URL PUBLICA. Usamos
# la URL "raw" de GitHub. Para que funcione:
#   1) El repo github.com/juancruzeiriz/nicho debe ser PUBLICO.
#   2) Tenés que hacer push de la carpeta products/*/pins/ (git add + commit + push).
# Si el repo es privado, cambia RAW_BASE por otro host (Imgur, Cloudinary, etc.)
# o subi los pines a mano (son 18, ~15 min).
import csv
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

# Base de las imagenes. Cambiala si el repo no es publico o usas otra rama/host.
RAW_BASE = 'https://raw.githubusercontent.com/juancruzeiriz/nicho/master/'

# Cargar PINS desde build_product_pins.py sin re-renderizar (respeta el guard main)
_spec = importlib.util.spec_from_file_location(
    'bpp', os.path.join(HERE, 'build_product_pins.py'))
bpp = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(bpp)

# Hashtags/keywords para la descripcion, por tablero
KW = {
    'Fitness & Nutrition': '#fitnesstracker #macrocalculator #tdee #weightloss #googlesheets #mealprep',
    'Stream Setup / Twitch': '#twitch #twitchalerts #streamer #obs #streaming #guitar',
}

OUT = os.path.join(HERE, 'pinterest_bulk.csv')
COLS = ['Title', 'Media URL', 'Pinterest board', 'Description', 'Link',
        'Publish date', 'Keywords']


def main():
    rows = []
    for spec in bpp.PINS:
        board = spec['board']
        for i, (hook, sub) in enumerate(spec['hooks'], 1):
            fname = f"{spec['prefix']}_{i:02d}.png"
            media = RAW_BASE + f"{spec['outdir']}/{fname}"
            desc = f"{sub} {KW.get(board, '')}".strip()
            rows.append({
                'Title': hook[:100],
                'Media URL': media,
                'Pinterest board': board,
                'Description': desc[:480],
                'Link': spec['link'],
                'Publish date': '',          # vacio = publicar ahora / programar a mano
                'Keywords': KW.get(board, ''),
            })
    with open(OUT, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=COLS)
        w.writeheader()
        w.writerows(rows)
    print(f'{len(rows)} filas -> {os.path.relpath(OUT, ROOT)}')
    print('Recorda: repo publico + push de products/*/pins/ para que las Media URL resuelvan.')


if __name__ == '__main__':
    main()
