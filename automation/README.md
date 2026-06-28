# automation/ — Bot de marketing diario (multi-plataforma)

Postea contenido a diario en Pinterest / YouTube / TikTok / Instagram desde una
cola, y arma drafts de Reddit para pegado manual. Corre en tu VM con cron.

## Mapa
- `config.yaml` — qué plataformas activas y en qué modo (live/draft/notify/off).
- `content_queue.py` — arma el catálogo desde los factories y elige el item del día.
- `platforms/` — un adapter por plataforma (interfaz `post(item, mode, cfg, dry_run)`).
- `run_daily.py` — el entrypoint del cron (rutea, loguea, notifica).
- `selftest.py` — valida config + tokens + cola sin postear.
- `notify.py` — resumen/alertas por Telegram o email.
- `get_youtube_token.py` — helper para el refresh_token de YouTube.
- `install.sh` + `DEPLOY.md` — montaje en la VM (venv aislado + cron).
- `SETUP_APIS.md` — cómo sacar cada token y dónde ponerlo.
- `secrets/` (ignorada por git) — tus tokens. `state/` — usage-log + cron.log.

## Estado por plataforma (al arrancar)
| Plataforma | Estado inicial | Pasa a full-auto cuando |
|---|---|---|
| Pinterest | ✅ live | — (ya) |
| YouTube | ✅ live | — (ya) |
| TikTok | ⏳ draft | aprueben el audit → `mode: live` |
| Instagram | ⛔ off | aprueben el app review → `enabled: true` + `media_base_url` |
| Reddit | ✍️ notify | (se queda manual por riesgo de ban) |

## Probar (sin tokens ni postear)
```bash
python -m automation.run_daily --dry-run
python -m automation.selftest
```

Pasos completos en `DEPLOY.md` y `SETUP_APIS.md`.
