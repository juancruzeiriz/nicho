# Helper de UNA sola vez: obtiene el refresh_token de YouTube y deja listo
# automation/secrets/youtube.json. Corrlo en tu PC (necesita navegador).
#
#   1) En Google Cloud Console: crea un proyecto, habilita "YouTube Data API v3",
#      pantalla de consentimiento OAuth (modo Testing, agregate como test user),
#      y crea credenciales OAuth de tipo "Desktop app". Baja el client_secret.json.
#   2) pip install google-auth-oauthlib
#   3) python automation/get_youtube_token.py ruta/al/client_secret.json
import json
import os
import sys

from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ['https://www.googleapis.com/auth/youtube.upload']


def main():
    cs = sys.argv[1] if len(sys.argv) > 1 else 'client_secret.json'
    flow = InstalledAppFlow.from_client_secrets_file(cs, SCOPES)
    creds = flow.run_local_server(port=0)
    with open(cs, encoding='utf-8') as f:
        c = json.load(f)
    c = c.get('installed') or c.get('web')
    out = {'client_id': c['client_id'], 'client_secret': c['client_secret'],
           'refresh_token': creds.refresh_token}
    os.makedirs('automation/secrets', exist_ok=True)
    p = 'automation/secrets/youtube.json'
    with open(p, 'w', encoding='utf-8') as f:
        json.dump(out, f, indent=2)
    print('Guardado', p, '- ya podes usar el adapter de YouTube.')


if __name__ == '__main__':
    main()
