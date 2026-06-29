# Instagram Graph API — publica Reels. Solo items 'video'. Requiere cuenta
# Business + app review aprobado. IG NO sube archivos: descarga el video de una
# URL PUBLICA, asi que necesita media_base_url en config (ej. tu landing/host).
# secrets/instagram.json = {"access_token": "...", "ig_user_id": "..."}
import time
from .base import Result, load_secret

GRAPH = 'https://graph.facebook.com/v21.0'


def post(item, mode, cfg, dry_run=False):
    if item.kind != 'video':
        return Result(True, 'instagram', mode, msg='skip (no es video)')
    if dry_run or mode != 'live':
        return Result(True, 'instagram', mode, msg='dry/skip')
    import requests
    sec = load_secret('instagram')
    token, ig = sec['access_token'], sec['ig_user_id']
    base = (cfg.get('media_base_url') or '').rstrip('/')
    if not base:
        return Result(False, 'instagram', mode,
                      msg='falta media_base_url en config (IG necesita URL publica del video)')
    video_url = f'{base}/{item.asset}'
    c = requests.post(f'{GRAPH}/{ig}/media', timeout=60, data={
        'media_type': 'REELS', 'video_url': video_url,
        'caption': item.caption, 'access_token': token}).json()
    cid = c.get('id')
    if not cid:
        return Result(False, 'instagram', mode, msg=f'container: {c}')
    for _ in range(25):   # esperar el procesamiento del video
        st = requests.get(f'{GRAPH}/{cid}', timeout=30, params={
            'fields': 'status_code', 'access_token': token}).json()
        code = st.get('status_code')
        if code == 'FINISHED':
            break
        if code == 'ERROR':
            return Result(False, 'instagram', mode, msg=f'proceso: {st}')
        time.sleep(6)
    p = requests.post(f'{GRAPH}/{ig}/media_publish', timeout=60, data={
        'creation_id': cid, 'access_token': token}).json()
    if p.get('id'):
        return Result(True, 'instagram', mode, ref=p['id'])
    return Result(False, 'instagram', mode, msg=f'publish: {p}')
