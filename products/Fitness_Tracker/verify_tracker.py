# Verificación sin Excel/LibreOffice (no hay ninguno en esta máquina):
# evalúa el workbook con la lib `formulas` y compara contra una
# reimplementación independiente. Correr: PYTHONIOENCODING=utf-8 python verify_tracker.py
# Caso de prueba: M, 30 años, 180cm, 80kg, Moderate, Cut, 2.0 g/kg.
import re
import formulas

w = [80.0, 80.3, 79.9, 80.1, 79.8, 79.9, 79.6, 79.8, 79.5, 79.7, 79.4, 79.2, 79.5, 79.1]
ma = lambda i: sum(w[max(0, i - 6):i + 1]) / len(w[max(0, i - 6):i + 1])

EXPECTED = {
    "SETUP'!B16": 1780.0, "SETUP'!B18": 2759.0, "SETUP'!B22": 2207.0,
    "SETUP'!B23": 160.0, "SETUP'!B24": 72.0, "SETUP'!B25": 230.0,
    "WEIGHT LOG'!C17": ma(13), "WEIGHT LOG'!D17": ma(13) - ma(6),
    "WEIGHT LOG'!E17": (ma(13) - ma(6)) / ma(13),
    "DASHBOARD'!B11": ma(13), "DASHBOARD'!B13": (ma(13) - ma(6)) / ma(13),
    "WORKOUT LOG'!F7": 119.6, "WORKOUT LOG'!G7": 'PR ★', "WORKOUT LOG'!G4": '',
    "DASHBOARD'!A16": 'On track — keep going.',
}

sol = formulas.ExcelModel().loads('Adaptive_Fitness_Tracker.xlsx').finish().calculate()
vals = {}
for k, v in sol.items():
    m = re.search(r"(SETUP|WEIGHT LOG|DASHBOARD|WORKOUT LOG)'![A-I]\d+$", k, re.I)
    if m and hasattr(v, 'value'):
        try:
            vals[m.group(0).upper()] = v.value[0, 0]
        except Exception:
            vals[m.group(0).upper()] = v.value

fails = 0
for k, want in EXPECTED.items():
    got = vals.get(k)
    if isinstance(want, float):
        ok = isinstance(got, (int, float)) and abs(got - want) < 0.01
    else:
        ok = str(got) == str(want)
    print('OK ' if ok else 'FAIL', k, '->', repr(got), '| esperado', repr(want))
    fails += 0 if ok else 1

errs = [k.split(']')[-1] for k, v in sol.items() if hasattr(v, 'value')
        and any(e in str(getattr(v, 'value', '')) for e in
                ('#REF!', '#DIV/0!', '#VALUE!', '#NAME?', '#N/A', '#NULL!'))]
print('celdas con error Excel:', len(errs), errs[:10])
print('RESULTADO:', 'PASS' if fails == 0 and not errs else f'FAIL ({fails} mismatches, {len(errs)} errores)')
