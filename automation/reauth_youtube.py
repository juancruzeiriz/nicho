# Re-genera el refresh_token de YouTube REUSANDO client_id/client_secret que ya
# estan en automation/secrets/youtube.json (no hace falta bajar client_secret.json).
# Abre el navegador: elegi tu cuenta y acepta los permisos. Guarda el token nuevo.
#
#   python automation/reauth_youtube.py
import json
import os

from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ['https://www.googleapis.com/auth/youtube.upload']
P = os.path.join('automation', 'secrets', 'youtube.json')


def main():
    s = json.load(open(P, encoding='utf-8'))
    client_config = {
        'installed': {
            'client_id': s['client_id'],
            'client_secret': s['client_secret'],
            'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
            'token_uri': 'https://oauth2.googleapis.com/token',
            'redirect_uris': ['http://localhost'],
        }
    }
    flow = InstalledAppFlow.from_client_config(client_config, SCOPES)
    creds = flow.run_local_server(
        port=0, access_type='offline', prompt='select_account consent')
    if not creds.refresh_token:
        raise SystemExit(
            'No vino refresh_token. Revoca el acceso en '
            'https://myaccount.google.com/permissions y volve a correr.')
    s['refresh_token'] = creds.refresh_token
    json.dump(s, open(P, 'w', encoding='utf-8'), indent=2)
    print('OK: refresh_token nuevo guardado en', P)


if __name__ == '__main__':
    main()
