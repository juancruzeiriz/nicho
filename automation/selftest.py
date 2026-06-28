# Chequeo de salud SIN postear: valida config, cola, assets y presencia de tokens.
# Con --net intenta una llamada "whoami" liviana por plataforma habilitada.
#   python -m automation.selftest
#   python -m automation.selftest --net
import argparse
import os

from . import content_queue as cq
from .config import load_config
from .platforms.base import abspath, load_secret

SECRET_NAME = {'pinterest': 'pinterest', 'youtube': 'youtube', 'tiktok': 'tiktok',
               'instagram': 'instagram', 'reddit': 'reddit'}


def _whoami(name):
    import requests
    if name == 'pinterest':
        t = load_secret('pinterest')['access_token']
        r = requests.get('https://api.pinterest.com/v5/user_account',
                         headers={'Authorization': f'Bearer {t}'}, timeout=30)
        return r.status_code == 200, r.status_code
    if name == 'instagram':
        s = load_secret('instagram')
        r = requests.get(f"https://graph.facebook.com/v21.0/{s['ig_user_id']}",
                         params={'fields': 'username', 'access_token': s['access_token']},
                         timeout=30)
        return r.status_code == 200, r.status_code
    return None, 'sin chequeo de red'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--net', action='store_true', help='probar tokens con una llamada liviana')
    a = ap.parse_args()

    cfg = load_config()
    print('== config ==')
    for n, pc in cfg.get('platforms', {}).items():
        print(f'  {n}: enabled={pc.get("enabled")} mode={pc.get("mode")}')

    print('== catalogo ==')
    cat = cq.build_catalog()
    missing = [it.id for it in cat if not os.path.exists(abspath(it.asset))]
    print(f'  {len(cat)} items; assets faltantes: {len(missing)}')
    for m in missing[:10]:
        print('   falta:', m)
    for k, v in cq.health(cat, cq.load_usage()).items():
        print(f'  {k}: {v["unused"]}/{v["total"]} sin usar (~{v["days_left"]} dias)')

    print('== tokens ==')
    for n, pc in cfg.get('platforms', {}).items():
        if not (pc.get('enabled') and pc.get('mode') in ('live', 'draft')):
            continue
        try:
            load_secret(SECRET_NAME[n])
            status = 'token presente'
            if a.net:
                ok, code = _whoami(n)
                if ok is not None:
                    status += f' | whoami: {"OK" if ok else "FALLO"} ({code})'
        except Exception as e:
            status = f'FALTA: {e}'
        print(f'  {n}: {status}')
    print('selftest done.')


if __name__ == '__main__':
    main()
