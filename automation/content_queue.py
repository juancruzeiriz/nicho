# Cola de contenido: arma el catalogo desde los factories existentes (pines y
# videos), elige el item del dia (least-recently-used) y reporta la "salud" del
# contenido fresco para el modo mezcla (autogenera + avisa cuando alimentar).
#
# Test rapido (sin tokens):  python -m automation.content_queue
from dataclasses import dataclass, asdict
import importlib.util
import json
import os
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
STATE_DIR = os.path.join(HERE, 'state')
USAGE = os.path.join(STATE_DIR, 'usage.json')

FIT_TAGS = '#fitnesstracker #macrocalculator #tdee #weightloss #googlesheets'
SFX_PIN_TAGS = '#twitch #twitchalerts #streamer #obs #guitar'
SFX_VID_TAGS = '#twitch #twitchalerts #smallstreamer #streamerlife #obs #guitar #fyp #shorts'


def _load_module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


@dataclass
class Item:
    id: str
    kind: str            # 'pin' | 'video'
    product: str         # 'fitness' | 'sfx'
    asset: str           # ruta relativa al repo
    title: str
    caption: str
    hashtags: str
    link: str
    platforms: list

    def to_dict(self):
        return asdict(self)


def build_catalog():
    """Reusa PINS y CLIPS como fuente unica de captions/links/assets."""
    items = []
    bpp = _load_module(os.path.join(ROOT, 'marketing', 'build_product_pins.py'), 'bpp')
    for spec in bpp.PINS:
        product = 'fitness' if 'Fitness' in spec['outdir'] else 'sfx'
        tags = FIT_TAGS if product == 'fitness' else SFX_PIN_TAGS
        for i, (hook, sub) in enumerate(spec['hooks'], 1):
            fname = f"{spec['prefix']}_{i:02d}.png"
            items.append(Item(
                id=fname, kind='pin', product=product,
                asset=f"{spec['outdir']}/{fname}",
                title=hook[:100], caption=f"{sub} {tags}".strip(),
                hashtags=tags, link=spec['link'], platforms=['pinterest']))
    bvc = _load_module(os.path.join(ROOT, 'products', 'Guitar_SFX_Pack',
                                    'build_video_clips.py'), 'bvc')
    sfx_link = next((s['link'] for s in bpp.PINS if 'Guitar' in s['outdir']), '')
    for audio, tone, event, accent, caption in bvc.CLIPS:
        stem = os.path.splitext(audio)[0]
        items.append(Item(
            id=f"{stem}.mp4", kind='video', product='sfx',
            asset=f"products/Guitar_SFX_Pack/video_clips/{stem}.mp4",
            title=caption[:100], caption=f"{caption} {SFX_VID_TAGS}".strip(),
            hashtags=SFX_VID_TAGS, link=sfx_link,
            platforms=['youtube', 'tiktok', 'instagram']))
    return items


def load_usage():
    if os.path.exists(USAGE):
        with open(USAGE, encoding='utf-8') as f:
            return json.load(f)
    return {}


def save_usage(u):
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(USAGE, 'w', encoding='utf-8') as f:
        json.dump(u, f, indent=2)


def _last(usage, item_id):
    return usage.get(item_id, {}).get('last', '')   # iso str, '' = nunca posteado


def pick_for_today(catalog, usage, pins=1, videos=1):
    """Elige los menos usados (los nunca posteados primero)."""
    picks = []
    for kind, n in (('pin', pins), ('video', videos)):
        pool = sorted((it for it in catalog if it.kind == kind),
                      key=lambda it: _last(usage, it.id))
        picks.extend(pool[:n])
    return picks


def mark_posted(usage, item_id, platforms_ok):
    rec = usage.get(item_id, {'count': 0})
    rec['last'] = datetime.now(timezone.utc).isoformat(timespec='seconds')
    rec['count'] = rec.get('count', 0) + 1
    rec.setdefault('platforms', {})
    for p in platforms_ok:
        rec['platforms'][p] = rec['last']
    usage[item_id] = rec
    return usage


def health(catalog, usage, pins_per_day=1, videos_per_day=1):
    out = {}
    for kind, per in (('pin', pins_per_day), ('video', videos_per_day)):
        pool = [it for it in catalog if it.kind == kind]
        unused = [it for it in pool if not _last(usage, it.id)]
        out[kind] = {'total': len(pool), 'unused': len(unused),
                     'days_left': round(len(unused) / per, 1) if per else 0}
    return out


def main():
    cat = build_catalog()
    usage = load_usage()
    npin = sum(1 for i in cat if i.kind == 'pin')
    nvid = sum(1 for i in cat if i.kind == 'video')
    print(f'Catalogo: {len(cat)} items ({npin} pines, {nvid} videos)\n')
    print('Salud del contenido fresco (sin usar):')
    for k, v in health(cat, usage).items():
        print(f'  {k}: {v["unused"]}/{v["total"]} sin usar -> ~{v["days_left"]} dias')
    print('\nElegidos para hoy:')
    for it in pick_for_today(cat, usage):
        exists = os.path.exists(os.path.join(ROOT, it.asset))
        flag = '' if exists else '  (!) FALTA ASSET'
        print(f'  [{it.kind}/{it.product}] {it.id} -> {it.platforms}{flag}')
        print(f'      "{it.title}"')


if __name__ == '__main__':
    main()
