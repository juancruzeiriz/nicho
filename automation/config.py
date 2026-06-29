import os
import yaml

HERE = os.path.dirname(os.path.abspath(__file__))


def load_config(path=None):
    path = path or os.path.join(HERE, 'config.yaml')
    with open(path, encoding='utf-8') as f:
        return yaml.safe_load(f)
