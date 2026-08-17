# Pinterest API v5 — sube pines (imagen en base64). Solo procesa items 'pin'.
# El access_token de Pinterest caduca a ~30 dias: si viene 401 y hay refresh_token
# + app_id/app_secret en el secret, lo renueva solo y persiste el nuevo token.
import base64
import json
import os
from .base import Result, abspath, load_secret, BOARDS, SECRETS

API = 'https://api.pinterest.com/v5'
_board_cache = {}


def _req(token, method, path, body=None):
    import requests
    r = requests.request(method, API + path, timeout=60, json=body,
                         headers={'Authorization': f'Bearer {token}',
                                  'Content-Type': 'application/json'})
    return r.status_code, (r.json() if r.content else {})


def _refresh(secret):
    """Renueva access_token con refresh_token; persiste y devuelve el token nuevo."""
    import requests
    if not (secret.get('refresh_token') and secret.get('app_id') and secret.get('app_secret')):
        return None
    r = requests.post(API + '/oauth/token', timeout=60,
                      headers={'Content-Type': 'application/x-www-form-urlencoded'},
                      data={'grant_type': 'refresh_token',
                            'refresh_token': secret['refresh_token']},
                      auth=(secret['app_id'], secret['app_secret']))
    if r.status_code != 200:
        return None
    tok = r.json()
    secret['access_token'] = tok['access_token']
    if tok.get('refresh_token'):
        secret['refresh_token'] = tok['refresh_token']
    with open(os.path.join(SECRETS, 'pinterest.json'), 'w', encoding='utf-8') as f:
        json.dump(secret, f, indent=2)
    return secret['access_token']


def _make_caller(secret):
    """Devuelve un requester que reintenta una vez si el token caduca (401)."""
    state = {'token': secret['access_token']}

    def call(method, path, body=None):
        st, data = _req(state['token'], method, path, body)
        if st == 401:
            new = _refresh(secret)
            if new:
                state['token'] = new
                st, data = _req(new, method, path, body)
        return st, data
    return call


def _board_id(call, name):
    if name in _board_cache:
        return _board_cache[name]
    st, data = call('GET', '/boards?page_size=100')
    if st == 200:
        for b in data.get('items', []):
            if b.get('name', '').lower() == name.lower():
                _board_cache[name] = b['id']
                return b['id']
    st, data = call('POST', '/boards', {'name': name, 'privacy': 'PUBLIC'})
    if st in (200, 201):
        _board_cache[name] = data['id']
        return data['id']
    raise RuntimeError(f'board "{name}": {st} {data}')


def post(item, mode, cfg, dry_run=False):
    if item.kind != 'pin':
        return Result(True, 'pinterest', mode, msg='skip (no es pin)')
    if dry_run or mode != 'live':
        return Result(True, 'pinterest', mode, msg='dry/skip')
    call = _make_caller(load_secret('pinterest'))
    board_id = _board_id(call, BOARDS.get(item.product, item.product))
    with open(abspath(item.asset), 'rb') as f:
        b64 = base64.b64encode(f.read()).decode()
    st, data = call('POST', '/pins', {
        'board_id': board_id, 'title': item.title[:100],
        'description': item.caption[:500], 'link': item.link,
        'media_source': {'source_type': 'image_base64',
                         'content_type': 'image/png', 'data': b64},
    })
    if st in (200, 201):
        return Result(True, 'pinterest', mode, ref=data.get('id', ''))
    return Result(False, 'pinterest', mode, msg=f'{st} {data}')
