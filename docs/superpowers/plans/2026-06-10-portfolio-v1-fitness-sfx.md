# Portfolio v1 — Plantilla Fitness (#1) + Pack SFX Guitarra (#2) — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir los dos primeros productos de la nueva dirección (OPORTUNIDADES.md §3): la plantilla Excel de fitness/nutrición y el pack de SFX de guitarra real, con validación de demanda previa, copy de listing en inglés, hoja de métricas y CLAUDE.md actualizado.

**Architecture:** Productos nuevos viven en `products/` (separados de `packs/`, que es el catálogo viejo de overlays). El xlsx se construye con openpyxl vía la skill `anthropic-skills:xlsx` (REQUIRED SUB-SKILL en Task 2). El pack SFX no procesa audio agent-side (no hay ffmpeg): entrega estructura, licencias, copy y un script PowerShell que el usuario corre para empaquetar.

**Tech Stack:** Python 3.12 + openpyxl (instalar), PowerShell (`Compress-Archive`), WebSearch para validación, Markdown para copy/docs.

**Restricciones heredadas (HANDOFF.md):** no ImageMagick agent-side; no `powershell.exe` vía Bash; docs internos en rioplatense/voseo; productos y listings en inglés (decisión: inglés primero); no tocar info personal del README.

---

### Task 1: Validación de demanda (regla de oro de OPORTUNIDADES.md §5)

**Files:**
- Create: `VALIDACION.md`

- [ ] **Step 1: Buscar evidencia de demanda para #1 (plantilla fitness)**

Correr WebSearch con estas queries (mínimo 3):
- `etsy best selling fitness tracker spreadsheet macro calculator`
- `gumroad fitness nutrition spreadsheet template sales`
- `"workout tracker" OR "macro tracker" spreadsheet template buy site:etsy.com OR site:gumroad.com`

Qué anotar por cada hallazgo: producto, plataforma, precio, nº de reviews/ratings (proxy de ventas), qué incluye.

- [ ] **Step 2: Buscar evidencia de demanda para #2 (SFX alertas de guitarra)**

Queries:
- `twitch alert sounds pack buy itch.io gumroad`
- `stream alert sound effects pack best sellers`
- `guitar stinger sound effects streamers`

Qué anotar: ídem Step 1 + si existe el ángulo "real guitar" o está vacío.

- [ ] **Step 3: Escribir `VALIDACION.md`**

Estructura del archivo (en rioplatense):

```markdown
# Validación de demanda — 2026-06-10
## #1 Plantilla fitness/nutrición
| Producto comparable | Plataforma | Precio | Reviews/ratings | Incluye |
(tabla con 3-5 filas reales)
**Veredicto:** GO / NO-GO + por qué.
## #2 Pack SFX guitarra
(ídem)
**Veredicto:** GO / NO-GO + por qué.
## Implicancias para el build
(qué features/keywords aparecen en los top sellers que tenemos que cubrir)
```

- [ ] **Step 4: Gate de decisión**

Criterio GO para #1: existen ≥3 productos comparables con ≥50 reviews/ratings en Etsy o Gumroad.
Criterio GO para #2: existen packs de alert sounds con ventas visibles en itch/Gumroad (≥10 ratings) — el ángulo "real guitar" vacío es BUENO (diferenciador), el problema sería que no se vendan alert sounds en general.
Si alguno da NO-GO: no construir ese producto, reportar al usuario y seguir con el otro.

- [ ] **Step 5: Commit**

```bash
git add VALIDACION.md
git commit -m "Validacion de demanda para plantilla fitness y pack SFX"
```

---

### Task 2: Construir el xlsx — Adaptive Fitness Tracker (producto #1)

**REQUIRED SUB-SKILL:** `anthropic-skills:xlsx` — invocarla ANTES de escribir código openpyxl; su guía de construcción/verificación manda sobre los detalles de implementación de esta task.

**Files:**
- Create: `products/Fitness_Tracker/Adaptive_Fitness_Tracker.xlsx`
- Create: `products/Fitness_Tracker/build_tracker.py` (script generador, se versiona para poder regenerar)

- [ ] **Step 1: Instalar openpyxl**

Run: `pip install openpyxl`
Expected: instalación limpia (Python 3.12.7 ya verificado).

- [ ] **Step 2: Invocar la skill xlsx y construir el workbook con esta especificación exacta**

Idioma del producto: **inglés**. Unidades: dropdown Metric/Imperial con conversión interna a kg/cm.

**Sheet 1 — `Dashboard`:**
- Targets actuales (calorías, proteína/grasa/carbos en g) referenciando `Setup`.
- Peso de tendencia actual (última media móvil de `Weight Log`), tasa semanal (kg o lb/semana y % del peso corporal).
- Celda "Coach suggestion" con lógica adaptativa:
  - Si Goal=Cut y la tasa semanal > -0.25% del peso → "Trend is flat: reduce ~150 kcal or add 2k steps/day".
  - Si Goal=Cut y la tasa < -1.0% → "Losing too fast: add ~150 kcal to protect muscle".
  - Si Goal=Bulk y la tasa < +0.1% → "Not gaining: add ~150 kcal".
  - Si Goal=Bulk y la tasa > +0.5% → "Gaining too fast: cut ~100 kcal".
  - Caso contrario → "On track — keep going".
- Gráfico de línea: peso diario + media móvil 7 días.

**Sheet 2 — `Setup`:**
- Inputs con validación: Sex (M/F), Age, Height, Weight, Units (Metric/Imperial), Activity (5 niveles), Goal (Cut/Maintain/Bulk), Protein level (g/kg: 1.6/1.8/2.0/2.2).
- BMR Mifflin-St Jeor: `=10*kg + 6.25*cm - 5*Age + IF(Sex="M",5,-161)`.
- TDEE = BMR × multiplicador: Sedentary 1.2 / Light 1.375 / Moderate 1.55 / Very 1.725 / Athlete 1.9.
- Target kcal = TDEE × (Cut: 0.80 / Maintain: 1.00 / Bulk: 1.10).
- Protein g = kg × protein_level; Fat g = kg × 0.9; Carbs g = (Target − P×4 − F×9) / 4.

**Sheet 3 — `Weight Log`:**
- Columnas: Date, Weight, 7-day MA (`AVERAGE` de las últimas 7, mostrar desde ≥3 datos), Weekly trend (MA hoy − MA hace 7 filas), % of bodyweight.
- ~120 filas pre-formateadas.

**Sheet 4 — `Workout Log`:**
- Columnas: Date, Exercise (dropdown desde lista editable), Weight, Reps, RIR (0-5), e1RM Epley `=Weight*(1+Reps/30)`, PR flag (e1RM > máximo histórico del ejercicio).
- ~200 filas pre-formateadas + tabla de ejercicios editable (15 básicos: squat, bench, deadlift, OHP, row, etc.).

**Sheet 5 — `Guide`:**
- Cómo empezar (3 pasos), por qué media móvil y no peso diario, qué es RIR, cuándo ajustar calorías (regla: esperar 2 semanas de datos), disclaimer no-médico.

- [ ] **Step 3: Verificar el workbook**

Según el flujo de verificación de la skill xlsx (recálculo). Mínimo: recomputar a mano un caso de prueba — M, 30 años, 180cm, 80kg, Moderate, Cut, 2.0 g/kg → BMR 1780, TDEE 2759, Target 2207, P 160g, F 72g, C 230g — y verificar que las celdas den eso.

- [ ] **Step 4: Commit**

```bash
git add products/Fitness_Tracker/
git commit -m "Producto #1: Adaptive Fitness Tracker (xlsx) con TDEE, macros, tendencia y RIR"
```

---

### Task 3: Listing copy del producto #1 (EN)

**Files:**
- Create: `products/Fitness_Tracker/LISTING_EN.md`

- [ ] **Step 1: Escribir el listing**

Contenido exacto a desarrollar (títulos y tags ya decididos, descripción se redacta completa en este step):

- **Título Etsy (≤140 chars):** `Macro Calculator & Weight Trend Tracker Spreadsheet | TDEE, Cut/Bulk Planner, Workout Log with RIR | Excel + Google Sheets`
- **13 tags Etsy:** macro calculator, tdee calculator, weight loss tracker, fitness spreadsheet, workout log, calorie tracker, cut bulk planner, gym tracker excel, nutrition template, weight trend, progressive overload, fitness planner, macro tracker.
- **Precio:** $14 Etsy / $12 Gumroad (rango $9–19 de OPORTUNIDADES.md).
- **Descripción:** hook (el problema: el peso diario miente, las plantillas genéricas son tablas tontas), qué incluye (5 sheets), el diferenciador (lógica adaptativa de coach + criterio real de entrenamiento), cómo se entrega, FAQ (¿sirve en Google Sheets? sí), disclaimer.
- **Sección Gumroad:** misma base, formato largo con headers.

- [ ] **Step 2: Commit**

```bash
git add products/Fitness_Tracker/LISTING_EN.md
git commit -m "Listing EN del Fitness Tracker para Etsy y Gumroad"
```

---

### Task 4: Pack SFX de guitarra (producto #2) — estructura, licencias, copy y empaquetador

**Files:**
- Create: `products/Guitar_SFX_Pack/README_PACK.md` (inventario + plan de grabación faltante)
- Create: `products/Guitar_SFX_Pack/LICENSE_Standard.txt`
- Create: `products/Guitar_SFX_Pack/LICENSE_Commercial.txt`
- Create: `products/Guitar_SFX_Pack/LISTING_EN.md`
- Create: `products/Guitar_SFX_Pack/build_sfx_pack.ps1`

- [ ] **Step 1: Inventario y naming**

Mapa de renombre (los 6 MP3 existentes en `audios/` + objetivo 15-20 sonidos):

| Origen | Nombre en pack |
|---|---|
| alert-clean-1.mp3 | RGSP_Clean_Alert_01.mp3 |
| alert-clean-2.mp3 | RGSP_Clean_Alert_02.mp3 |
| alert-overdrive-1.mp3 | RGSP_Overdrive_Alert_01.mp3 |
| alert-overdrive-2.mp3 | RGSP_Overdrive_Alert_02.mp3 |
| alert-fuzz-1.mp3 | RGSP_Fuzz_Alert_01.mp3 |
| alert-fuzz-2.mp3 | RGSP_Fuzz_Alert_02.mp3 |

Faltantes a grabar (van como checklist para el usuario en README_PACK.md): 4 stingers cortos (<2s) por tono, 2 transiciones (3-5s), 2 "raid" intensos fuzz. Specs de export: WAV 48kHz/24-bit + MP3 320kbps, normalizado a −14 LUFS (en Reaper).

- [ ] **Step 2: Licencias**

`LICENSE_Standard.txt` (EN): uso personal en streams/videos del comprador, monetización de contenido OK, prohibido revender/redistribuir los archivos como audio, no requiere atribución.
`LICENSE_Commercial.txt` (EN): agrega uso en proyectos de clientes, juegos y apps; mismas prohibiciones de reventa standalone.

- [ ] **Step 3: Listing EN**

- **Título itch.io:** `Real Guitar Stream Alerts — Boutique Tone SFX Pack`
- **Ángulo de copy:** "Recorded on a real guitar through a boutique Artemis overdrive and a germanium fuzz — not a synth preset" (chequear contra README antes de citar el setup: la info personal no se inventa ni se amplía).
- **Precio:** itch.io pay-what-you-want piso $5 / Gumroad $10 standard, $18 commercial.
- Incluir: lista de contenidos, formatos, licencias, "works with Streamlabs/StreamElements/OBS".

- [ ] **Step 4: Script empaquetador `build_sfx_pack.ps1`**

PowerShell (lo corre el usuario, como los otros .ps1): copia `audios/*.mp3` al staging con los nombres del mapa, agrega licencias + README, valida `Test-Path` por archivo (patrón de build_all.ps1, fix T3), y arma `RealGuitar_SFX_Pack.zip` con `Compress-Archive`. Param `-IncludeWav` para cuando existan los WAV.

- [ ] **Step 5: Commit**

```bash
git add products/Guitar_SFX_Pack/
git commit -m "Producto #2: estructura del pack SFX de guitarra (licencias, listing, empaquetador)"
```

---

### Task 5: Hoja de métricas (fix de B7)

**Files:**
- Create: `metricas/metricas.csv`
- Create: `metricas/README.md`

- [ ] **Step 1: Crear el CSV con el header de OPORTUNIDADES.md §5**

```csv
fecha,producto,plataforma,vistas,favoritos,conversiones,ingreso_usd,precio,fuente_trafico,nota
```

`README.md`: cómo llenarla (1 fila por producto×plataforma×semana), y la regla validar-antes-de-construir.

- [ ] **Step 2: Commit**

```bash
git add metricas/
git commit -m "Hoja de metricas semanal (fix B7)"
```

---

### Task 6: Actualizar CLAUDE.md al encuadre nuevo

**Files:**
- Modify: `CLAUDE.md` (secciones "Stream Assets Business" y "Estado actual")

- [ ] **Step 1: Reescribir el encabezado y estado**

- Título/intro: portfolio multi-skill de productos digitales (RiffStream), meta ingreso recurrente USD mundial, inglés primero. Apuntar a `OPORTUNIDADES.md` como doc de dirección.
- "Estado actual": overlays = catálogo terminado (no foco); en construcción #1 y #2 en `products/`; mantener las convenciones y la sección "Para Claude Code" sin cambios.
- NO tocar la sección de info personal.

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "CLAUDE.md: actualiza al encuadre portfolio (direccion en OPORTUNIDADES.md)"
```

---

## Self-review

- **Cobertura:** §7 de OPORTUNIDADES pasos 2 (validar → Task 1), 3 (#1 → Tasks 2-3), 4 (#2 → Task 4), 5 (métricas → Task 5); CLAUDE.md viejo (HANDOFF ⚠️ → Task 6). Paso 6 (#5 widgets) y 7 (reciclar overlays) quedan explícitamente fuera (después de medir).
- **Sin placeholders:** fórmulas, mapa de renombre, títulos, tags y precios están definidos; la prosa larga de listings se redacta en su step con la estructura fijada.
- **Consistencia:** prefijo de archivos SFX `RGSP_` usado en naming y script; rutas `products/...` consistentes entre Tasks 2-4.
