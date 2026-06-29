# Deploy del bot de marketing en tu VM de Google

> Corre **aislado** del bot de trading: su propio venv y su propia línea de cron.
> No toca nada del trading.

## Requisitos en la VM
- Linux con **python3** (3.9+) y **cron**.
- Salida HTTPS (las APIs son llamadas web).
- Los **assets** (pines en `products/*/pins/`, videos en
  `products/Guitar_SFX_Pack/video_clips/`) presentes. Vienen con el repo si los
  commiteás/pusheás; o se regeneran en la VM (necesita Pillow para pines y ffmpeg
  para videos).

## Pasos (una vez)
1. **Traé el repo a la VM** (una de las dos):
   - `git clone https://github.com/juancruzeiriz/nicho.git` (o `git pull` si ya está).
   - o `scp -r` la carpeta desde tu PC.
2. **Instalá** (crea venv aislado + deps):
   ```bash
   bash automation/install.sh
   ```
3. **Cargá los tokens** en `automation/secrets/` (ver `SETUP_APIS.md`). Esa
   carpeta está ignorada por git: los tokens nunca se suben.
4. **Probá sin postear:**
   ```bash
   automation/.venv/bin/python -m automation.selftest        # valida config+tokens+cola
   automation/.venv/bin/python -m automation.run_daily --dry-run
   ```
5. **Probá 1 post real** (cuando los tokens estén): bajá `pins_per_day`/`videos_per_day`
   si querés, y corré sin `--dry-run`. Revisá que aparezca el pin/video/borrador.
6. **Agendá el cron** (1 corrida por día, ej. 14:00 UTC):
   ```bash
   crontab -e
   # pegá:
   0 14 * * * cd /ruta/al/repo && automation/.venv/bin/python -m automation.run_daily >> /ruta/al/repo/automation/state/cron.log 2>&1
   ```

## Operación
- **Logs:** `automation/state/cron.log` (cada corrida) + el resumen te llega por
  el notificador (Telegram/email, según `config.yaml` + `secrets/`).
- **Activar/desactivar plataformas:** editá `automation/config.yaml`
  (`enabled` y `mode`). TikTok pasa de `draft` a `live` cuando te aprueben el
  audit; Instagram pasa a `enabled: true` cuando te aprueben el app review.
- **Sumar contenido fresco** (modo mezcla): agregá hooks en
  `marketing/build_product_pins.py` / clips en
  `products/Guitar_SFX_Pack/build_video_clips.py`, regenerá, y `git pull` en la VM.
  El bot avisa por el notificador cuando el contenido fresco baja del umbral.

## Si me das acceso SSH, lo deployo yo
Pasame IP/usuario/llave (o agregás mi clave). Hago install + selftest y te dejo el
cron andando. Igual los **tokens los cargás vos** en `secrets/` (no los veo).
