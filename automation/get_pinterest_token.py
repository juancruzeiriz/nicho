# Helper de UNA vez: obtiene access_token + refresh_token de Pinterest (API v5)
# y deja listo automation/secrets/pinterest.json. Corrlo en tu PC (abre navegador).
#
#   1) developers.pinterest.com -> crea/abri tu app (cuenta business).
#      Scopes: boards:read, boards:write, pins:read, pins:write.
#   2) En la config de la app, agrega EXACTAMENTE este redirect URI:
#         http://localhost:8085/
#   3) Corre:  python automation/get_pinterest_token.py <APP_ID> <APP_SECRET>
#      (o exporta PINTEREST_APP_ID / PINTEREST_APP_SECRET y corre sin args)
import base64
import http.server
import json
import os
import sys
import threading
import urllib.parse
import urllib.request
import webbrowser

REDIRECT = 'http://localhost:8085/'
PORT = 8085
SCOPES = 'boards:read,boards:write,pins:read,pins:write'
AUTH = 'https://www.pinterest.com/oauth/'
TOKEN = 'https://api.pinterest.com/v5/oauth/token'
OUT = os.path.join('automation', 'secrets', 'pinterest.json')

_code = {}


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        q = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(q)
        _code['code'] = params.get('code', [None])[0]
        _code['error'] = params.get('error', [None])[0]
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        msg = 'OK, ya podes cerrar esta pestana.' if _code['code'] else 'Error en la autorizacion.'
        self.wfile.write(('<h2>%s</h2>' % msg).encode())

    def log_message(self, *a):
        pass


def _exchange(app_id, app_secret, body):
    data = urllib.parse.urlencode(body).encode()
    basic = base64.b64encode(f'{app_id}:{app_secret}'.encode()).decode()
    req = urllib.request.Request(TOKEN, data=data, headers={
        'Authorization': f'Basic {basic}',
        'Content-Type': 'application/x-www-form-urlencoded'})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def main():
    app_id = (sys.argv[1] if len(sys.argv) > 1 else os.environ.get('PINTEREST_APP_ID', '')).strip()
    app_secret = (sys.argv[2] if len(sys.argv) > 2 else os.environ.get('PINTEREST_APP_SECRET', '')).strip()
    if not app_id or not app_secret:
        sys.exit('Falta APP_ID / APP_SECRET. Uso: python automation/get_pinterest_token.py <APP_ID> <APP_SECRET>')

    srv = http.server.HTTPServer(('localhost', PORT), Handler)
    threading.Thread(target=srv.handle_request, daemon=True).start()

    url = AUTH + '?' + urllib.parse.urlencode({
        'client_id': app_id, 'redirect_uri': REDIRECT,
        'response_type': 'code', 'scope': SCOPES, 'state': 'riffstream'})
    print('Abriendo navegador para autorizar... Si no abre, pega esta URL:\n', url)
    webbrowser.open(url)

    # espera a que el server reciba el callback
    import time
    for _ in range(300):
        if _code.get('code') or _code.get('error'):
            break
        time.sleep(1)
    if not _code.get('code'):
        sys.exit('No llego el code (%s). Revisa que el redirect URI de la app sea %s'
                 % (_code.get('error'), REDIRECT))

    tok = _exchange(app_id, app_secret, {
        'grant_type': 'authorization_code',
        'code': _code['code'], 'redirect_uri': REDIRECT})
    out = {
        'access_token': tok['access_token'],
        'refresh_token': tok.get('refresh_token', ''),
        'app_id': app_id, 'app_secret': app_secret,
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(out, f, indent=2)
    print('OK: guardado', OUT, '- refresh_token:', 'si' if out['refresh_token'] else 'NO')


if __name__ == '__main__':
    main()
