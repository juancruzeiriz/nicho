# YouTube Data API v3 — sube el video como Short publico. Solo items 'video'.
# secrets/youtube.json = {"client_id","client_secret","refresh_token"}
from .base import Result, abspath, load_secret


def _service():
    from google.oauth2.credentials import Credentials
    from googleapiclient.discovery import build
    s = load_secret('youtube')
    creds = Credentials(
        None, refresh_token=s['refresh_token'],
        token_uri='https://oauth2.googleapis.com/token',
        client_id=s['client_id'], client_secret=s['client_secret'],
        scopes=['https://www.googleapis.com/auth/youtube.upload'])
    return build('youtube', 'v3', credentials=creds, cache_discovery=False)


def post(item, mode, cfg, dry_run=False):
    if item.kind != 'video':
        return Result(True, 'youtube', mode, msg='skip (no es video)')
    if dry_run or mode != 'live':
        return Result(True, 'youtube', mode, msg='dry/skip')
    from googleapiclient.http import MediaFileUpload
    yt = _service()
    title = (item.title[:90] + ' #Shorts')[:100]
    body = {
        'snippet': {
            'title': title, 'description': item.caption,
            'tags': [t.lstrip('#') for t in item.hashtags.split()][:15],
            'categoryId': '10',   # Music
        },
        'status': {'privacyStatus': 'public', 'selfDeclaredMadeForKids': False},
    }
    media = MediaFileUpload(abspath(item.asset), mimetype='video/mp4',
                            chunksize=-1, resumable=True)
    resp = yt.videos().insert(part='snippet,status', body=body,
                              media_body=media).execute()
    vid = resp.get('id', '')
    return Result(True, 'youtube', mode, ref=f'https://youtu.be/{vid}' if vid else '')
