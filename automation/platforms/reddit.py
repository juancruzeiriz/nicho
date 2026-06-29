# Reddit — por seguridad NO se auto-blastea (autopostear promo = ban). Default
# 'notify': devuelve el texto listo y el notifier te lo manda para pegado manual.
# 'live' SOLO si configuras un subreddit permitido y aceptas el riesgo (cadencia
# baja, value-first). secrets/reddit.json = {client_id, client_secret, username,
# password, user_agent}.
from .base import Result, load_secret


def _draft(item):
    return f'TITULO: {item.title}\n\n{item.caption}\n\nLink: {item.link}'


def post(item, mode, cfg, dry_run=False):
    if item.kind != 'pin' and item.kind != 'video':
        return Result(True, 'reddit', mode, msg='skip')
    if mode != 'live' or dry_run:
        return Result(True, 'reddit', 'notify', msg='draft para pegar', ref=_draft(item))
    sub = (cfg.get('subreddit') or '').strip()
    if not sub:
        return Result(True, 'reddit', 'notify',
                      msg='sin subreddit configurado -> queda en draft', ref=_draft(item))
    import praw
    s = load_secret('reddit')
    reddit = praw.Reddit(
        client_id=s['client_id'], client_secret=s['client_secret'],
        username=s['username'], password=s['password'],
        user_agent=s.get('user_agent', 'riffstream-marketing-bot'))
    sub_obj = reddit.subreddit(sub)
    submission = sub_obj.submit(title=item.title, selftext=f'{item.caption}\n\nLink: {item.link}')
    return Result(True, 'reddit', 'live', ref=f'https://reddit.com{submission.permalink}')
