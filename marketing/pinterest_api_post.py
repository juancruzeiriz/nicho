# Sube los pines a Pinterest por la API v5 (sin hosting: manda la imagen en
# base64). Reusa la config de build_product_pins.py.
#
#   # 1) Vista previa SIN postear (siempre arranca asi, es lo seguro):
#   python marketing/pinterest_api_post.py
#   # 2) Postear de verdad (requiere --go explicito):
#   python marketing/pinterest_api_post.py --go
#
# TOKEN (el script NUNCA lo recibe por chat; lo lee de tu entorno):
#   - Variable de entorno  PINTEREST_ACCESS_TOKEN, o
#   - Archivo  marketing/secrets/pinterest_token.txt  (ignorado por git)
#
# Como conseguir el token (una vez):
#   1. developers.pinterest.com -> crea una app (cuenta business).
#   2. Pedi los scopes  boards:read, boards:write, pins:read, pins:write.
#   3. Genera un access token (OAuth) y pegalo en marketing/secrets/pinterest_token.txt
#      o exportalo:  export PINTEREST_ACCESS_TOKEN=xxxx
#   Nota: las apps nuevas arrancan en "trial" -> alcanza para postear en TU cuenta
#   (rate limitado). Si algo da 403/401, revisa scopes o reautoriza.
import base64
import importlib.util
import json
import os
import sys
import time
import urllib.error
import urllib.request

API = 'https://api.pinterest.com/v5'
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

KW = {
    'Fitness & Nutrition': '#fitnesstracker #macrocalculator #tdee #weightloss #googlesheets',
    'Stream Setup / Twitch': '#twitch #twitchalerts #streamer #obs #guitar',
}


def get_token():
    t = os.environ.get('PINTEREST_ACCESS_TOKEN')
    if t:
        return t.strip()
    p = os.path.join(HERE, 'secrets', 'pinterest_token.txt')
    if os.path.exists(p):
        with open(p, encoding='utf-8') as f:
            return f.read().strip()
    sys.exit('FALTA token: defini PINTEREST_ACCESS_TOKEN o crea '
             'marketing/secrets/pinterest_token.txt (ver cabecera).')


def load_pins():
    spec = importlib.util.spec_from_file_location(
        'bpp', os.path.join(HERE, 'build_product_pins.py'))
    bpp = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(bpp)
    return bpp.PINS


def api(token, method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + path, data=data, method=method)
    req.add_header('Authorization', 'Bearer ' + token)
    req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, json.loads(r.read() or b'{}')
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read() or b'{}')


def get_or_create_board(token, name, cache):
    if name in cache:
        return cache[name]
    # buscar entre los boards existentes (paginado simple)
    st, data = api(token, 'GET', '/boards?page_size=100')
    if st == 200:
        for b in data.get('items', []):
            if b.get('name', '').lower() == name.lower():
                cache[name] = b['id']
                return b['id']
    # crear si no existe
    st, data = api(token, 'POST', '/boards', {'name': name, 'privacy': 'PUBLIC'})
    if st in (200, 201):
        cache[name] = data['id']
        print(f'  + board creado: {name}')
        return data['id']
    sys.exit(f'No pude obtener/crear el board "{name}": {st} {data}')


def main():
    go = '--go' in sys.argv
    pins = load_pins()
    total = sum(len(s['hooks']) for s in pins)
    print(f'{"POSTEANDO" if go else "DRY-RUN (no postea, usa --go)"} - {total} pines\n')

    token = get_token() if go else None
    cache = {}
    posted = 0
    for spec in pins:
        board_id = get_or_create_board(token, spec['board'], cache) if go else '(board)'
        for i, (hook, sub) in enumerate(spec['hooks'], 1):
            fname = f"{spec['prefix']}_{i:02d}.png"
            path = os.path.join(ROOT, spec['outdir'], fname)
            desc = f"{sub} {KW.get(spec['board'], '')}".strip()[:500]
            if not go:
                print(f'  [{spec["board"]}] {fname} -> "{hook[:60]}"')
                continue
            with open(path, 'rb') as f:
                b64 = base64.b64encode(f.read()).decode()
            body = {
                'board_id': board_id,
                'title': hook[:100],
                'description': desc,
                'link': spec['link'],
                'media_source': {
                    'source_type': 'image_base64',
                    'content_type': 'image/png',
                    'data': b64,
                },
            }
            st, data = api(token, 'POST', '/pins', body)
            if st in (200, 201):
                posted += 1
                print(f'  OK  {fname} -> pin {data.get("id", "?")}')
            else:
                print(f'  ERR {fname}: {st} {data}')
            time.sleep(2)  # cortesia con el rate limit
    if go:
        print(f'\nListo: {posted}/{total} pines posteados.')
    else:
        print('\nDry-run ok. Cuando tengas el token, corre con --go.')


if __name__ == '__main__':
    main()
