# Adapters de plataforma. Import perezoso: solo se importa (y exige sus deps) la
# plataforma que realmente se usa, asi el paquete no rompe si falta una lib.
import importlib

_KNOWN = ('pinterest', 'youtube', 'tiktok', 'instagram', 'reddit')


def get_adapter(name):
    if name not in _KNOWN:
        raise ValueError(f'plataforma desconocida: {name}')
    mod = importlib.import_module(f'automation.platforms.{name}')
    return mod.post
