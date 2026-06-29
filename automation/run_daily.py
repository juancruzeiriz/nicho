# Entrypoint del cron diario. Toma el/los item(s) del dia, los rutea a las
# plataformas habilitadas (respetando su modo), actualiza el usage-log, y manda
# un resumen + drafts de Reddit + aviso si el contenido fresco esta bajo.
#
#   python -m automation.run_daily --dry-run   # prueba sin postear ni tokens
#   python -m automation.run_daily             # corrida real (la del cron)
import argparse

from . import content_queue as cq
from . import notify
from .config import load_config
from .platforms import get_adapter
from .platforms.base import Result


def run(dry_run=False, config_path=None):
    cfg = load_config(config_path)
    sched = cfg.get('schedule', {})
    platforms_cfg = cfg.get('platforms', {})
    catalog = cq.build_catalog()
    usage = cq.load_usage()

    picks = cq.pick_for_today(catalog, usage,
                              sched.get('pins_per_day', 1),
                              sched.get('videos_per_day', 1))
    lines, drafts = [], []
    for item in picks:
        posted_live = []
        for pname in item.platforms:
            pc = platforms_cfg.get(pname, {})
            if not pc.get('enabled'):
                continue
            mode = pc.get('mode', 'live')
            pcfg = dict(pc)
            pcfg['media_base_url'] = cfg.get('media_base_url')
            try:
                res = get_adapter(pname)(item, mode, pcfg, dry_run=dry_run)
            except Exception as e:
                res = Result(False, pname, mode, msg=f'EXC {e}')
            lines.append(f'{item.id}: {res.line()}')
            if res.ok and not dry_run and mode == 'live':
                posted_live.append(pname)
            if pname == 'reddit' and res.ref.startswith('TITULO'):
                drafts.append(res.ref)
        if posted_live and not dry_run:
            cq.mark_posted(usage, item.id, posted_live)

    # Reddit aparte: NO se auto-blastea (riesgo de ban). Si esta habilitado,
    # genera un draft listo para pegar a mano (o postea si configuraste subreddit).
    rc = platforms_cfg.get('reddit', {})
    if rc.get('enabled') and picks:
        try:
            res = get_adapter('reddit')(picks[0], rc.get('mode', 'notify'),
                                        dict(rc), dry_run=dry_run)
        except Exception as e:
            res = Result(False, 'reddit', rc.get('mode', 'notify'), msg=f'EXC {e}')
        if res.ref.startswith('TITULO'):
            drafts.append(res.ref)
        else:
            lines.append(f'reddit: {res.line()}')

    if not dry_run:
        cq.save_usage(usage)

    h = cq.health(catalog, usage, sched.get('pins_per_day', 1),
                  sched.get('videos_per_day', 1))
    low_thr = (cfg.get('content') or {}).get('low_threshold_days', 7)
    low = [f'{k} (~{v["days_left"]}d)' for k, v in h.items() if v['days_left'] < low_thr]

    body = '\n'.join(lines) or '(nada para postear)'
    if drafts:
        body += '\n\n--- Reddit: pegar a mano ---\n' + '\n\n'.join(drafts)
    if low:
        body += f'\n\n[!] Contenido fresco bajo: {", ".join(low)}. Suma material nuevo.'
    subject = (f'[RiffStream bot] {"DRY-RUN" if dry_run else "post diario"} '
               f'- {len(picks)} items')
    notify.send(cfg, subject, body)
    print(subject + '\n' + body)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dry-run', action='store_true',
                    help='no postea ni usa tokens; muestra qué haría')
    ap.add_argument('--config', default=None)
    a = ap.parse_args()
    run(dry_run=a.dry_run, config_path=a.config)


if __name__ == '__main__':
    main()
