# Pinterest API v5 — sube pines (imagen en base64). Solo procesa items 'pin'.
import base64
from .base import Result, abspath, load_secret, BOARDS

API = 'https://api.pinterest.com/v5'
_board_cache = {}


def _req(token, method, path, body=None):
    import requests
    r = requests.request(method, API + path, timeout=60, json=body,
                         headers={'Authorization': f'Bearer {token}',
                                  'Content-Type': 'application/json'})
    return r.status_code, (r.json() if r.content else {})


def _board_id(token, name):
    if name in _board_cache:
        return _board_cache[name]
    st, data = _req(token, 'GET', '/boards?page_size=100')
    if st == 200:
        for b in data.get('items', []):
            if b.get('name', '').lower() == name.lower():
                _board_cache[name] = b['id']
                return b['id']
    st, data = _req(token, 'POST', '/boards', {'name': name, 'privacy': 'PUBLIC'})
    if st in (200, 201):
        _board_cache[name] = data['id']
        return data['id']
    raise RuntimeError(f'board "{name}": {st} {data}')


def post(item, mode, cfg, dry_run=False):
    if item.kind != 'pin':
        return Result(True, 'pinterest', mode, msg='skip (no es pin)')
    if dry_run or mode != 'live':
        return Result(True, 'pinterest', mode, msg='dry/skip')
    token = load_secret('pinterest')['access_token']
    board_id = _board_id(token, BOARDS.get(item.product, item.product))
    with open(abspath(item.asset), 'rb') as f:
        b64 = base64.b64encode(f.read()).decode()
    st, data = _req(token, 'POST', '/pins', {
        'board_id': board_id, 'title': item.title[:100],
        'description': item.caption[:500], 'link': item.link,
        'media_source': {'source_type': 'image_base64',
                         'content_type': 'image/png', 'data': b64},
    })
    if st in (200, 201):
        return Result(True, 'pinterest', mode, ref=data.get('id', ''))
    return Result(False, 'pinterest', mode, msg=f'{st} {data}')
