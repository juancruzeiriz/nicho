#!/usr/bin/env bash
# Deploy del bot de marketing en la VM (Linux), AISLADO del bot de trading
# (venv propio, su propio cron). Idempotente: podes correrlo varias veces.
#
#   bash automation/install.sh
set -euo pipefail
cd "$(dirname "$0")/.."          # raiz del repo
D="automation"

echo ">> creando venv aislado en $D/.venv"
python3 -m venv "$D/.venv"
"$D/.venv/bin/pip" install --upgrade pip >/dev/null
"$D/.venv/bin/pip" install -r "$D/requirements.txt"

mkdir -p "$D/secrets" "$D/state"
chmod 700 "$D/secrets" || true

echo ""
echo ">> listo. Probá (sin postear):"
echo "   $D/.venv/bin/python -m automation.run_daily --dry-run"
echo "   $D/.venv/bin/python -m automation.selftest"
echo ""
echo ">> cuando tengas los tokens en $D/secrets/ (ver SETUP_APIS.md), agenda el cron:"
echo "   crontab -e   # y pega esta linea (postea 1 vez por dia, 14:00):"
echo "   0 14 * * * cd $(pwd) && $D/.venv/bin/python -m automation.run_daily >> $(pwd)/$D/state/cron.log 2>&1"
echo ""
echo ">> el bot de trading no se toca: este usa SU propio venv y SU propia linea de cron."
