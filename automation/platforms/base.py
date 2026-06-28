# Utilidades compartidas por los adapters.
import json
import os
from dataclasses import dataclass

HERE = os.path.dirname(os.path.abspath(__file__))
PKG = os.path.dirname(HERE)            # automation/
ROOT = os.path.dirname(PKG)            # raiz del repo
SECRETS = os.path.join(PKG, 'secrets')


@dataclass
class Result:
    ok: bool
    platform: str
    mode: str
    ref: str = ''        # id o URL del post creado
    msg: str = ''

    def line(self):
        state = 'OK ' if self.ok else 'ERR'
        return f'{state} {self.platform}/{self.mode}: {self.ref or self.msg}'


def abspath(rel):
    return rel if os.path.isabs(rel) else os.path.join(ROOT, rel)


def load_secret(name):
    """Lee automation/secrets/<name>.json. NUNCA viaja por chat ni a git."""
    p = os.path.join(SECRETS, name + '.json')
    if not os.path.exists(p):
        raise FileNotFoundError(
            f'falta secrets/{name}.json (ver automation/SETUP_APIS.md)')
    with open(p, encoding='utf-8') as f:
        return json.load(f)


# Mapeo producto -> tablero de Pinterest (mismo nombre que en build_product_pins)
BOARDS = {
    'fitness': 'Fitness & Nutrition',
    'sfx': 'Stream Setup / Twitch',
}
