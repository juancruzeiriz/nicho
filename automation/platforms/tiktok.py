# TikTok Content Posting API — sube el video. Solo items 'video'.
# Sin AUDIT aprobado solo se puede SELF_ONLY (borrador): el video queda en la app
# para que toques "publicar". Con audit -> PUBLIC_TO_EVERYONE (mode: live).
# secrets/tiktok.json = {"access_token": "..."}
import os
from .base import Result, abspath, load_secret

API = 'https://open.tiktokapis.com/v2'


def post(item, mode, cfg, dry_run=False):
    if item.kind != 'video':
        return Result(True, 'tiktok', mode, msg='skip (no es video)')
    if dry_run or mode == 'off':
        return Result(True, 'tiktok', mode, msg='dry/skip')
    import requests
    token = load_secret('tiktok')['access_token']
    path = abspath(item.asset)
    size = os.path.getsize(path)
    privacy = 'PUBLIC_TO_EVERYONE' if mode == 'live' else 'SELF_ONLY'
    H = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}
    init = requests.post(f'{API}/post/publish/video/init/', headers=H, timeout=60,
                         json={
                             'post_info': {'title': item.caption[:150],
                                           'privacy_level': privacy},
                             'source_info': {'source': 'FILE_UPLOAD',
                                             'video_size': size,
                                             'chunk_size': size,
                                             'total_chunk_count': 1},
                         }).json()
    data = init.get('data', {})
    upload_url, publish_id = data.get('upload_url'), data.get('publish_id')
    if not upload_url:
        return Result(False, 'tiktok', mode, msg=f'init: {init.get("error", init)}')
    with open(path, 'rb') as f:
        put = requests.put(upload_url, data=f.read(), timeout=300, headers={
            'Content-Range': f'bytes 0-{size - 1}/{size}',
            'Content-Type': 'video/mp4'})
    if put.status_code not in (200, 201):
        return Result(False, 'tiktok', mode, msg=f'upload http {put.status_code}')
    note = 'borrador (publicar en la app)' if privacy == 'SELF_ONLY' else 'publicado'
    return Result(True, 'tiktok', mode, ref=publish_id or '', msg=note)
