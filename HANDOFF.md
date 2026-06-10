# Handoff — Sesión RiffStream (proyecto `nicho`)

> Contexto para continuar el trabajo en otra sesión/agente. Generado 2026-06-10.

## Objetivo del usuario (la dirección ACTUAL)
Generar **ingreso mensual recurrente en USD, de cualquier cliente del mundo, con
productos de bajo esfuerzo de desarrollo**, apalancando 4 ejes: **programador, músico
(guitarra boutique), motos, nutrición/gym**.

⚠️ El `CLAUDE.md` describe el encuadre **viejo** (overlays en Etsy para hispanohablantes)
— **NO es la dirección actual**. La nueva está en `OPORTUNIDADES.md`.

## Decisiones tomadas
- **Alcance:** portfolio multi-skill (no solo overlays).
- **Mercado:** mundial / bilingüe, **inglés primero**.
- **Entregable de la sesión:** documento de oportunidades + fixes técnicos baratos (hecho).

## Hallazgo central
Los nichos (rock/gym/moto overlays) tienen **baja demanda**, no solo baja competencia. Los
"revenue" del README son **totales lifetime, no mensuales** ($75–289) → no alcanzan los
$100/mes. Etsy no es donde compran los streamers. El eje **programador** está sin explotar
como producto.

## Lo que se entregó (archivos)
1. **`OPORTUNIDADES.md`** (raíz, nuevo) — doc principal:
   - Reanálisis de los 3 nichos: Rock → audio como pack SFX standalone; Gym → plantillas de
     nutrición (no overlay); Moto → marca/contenido, no producto.
   - **Portfolio ranqueado de 8 oportunidades.** Arranque recomendado: **#1 plantilla de
     nutrición/fitness (Sheets/Excel)** + **#2 pack de SFX de guitarra real**. Mayor techo a
     futuro: **#5 widgets browser-source codeados**.
   - Falencias (B1–B7 negocio + técnicas), métricas a trackear, y fuentes públicas para
     validar demanda antes de construir.
   - Match producto↔plataforma: plantillas→Etsy+Gumroad+Payhip; audio→itch+Gumroad;
     widgets/código→Gumroad+itch; overlays→itch+Booth.
2. **`.gitignore`** — ignora screenshots/scratch (`FIGMA.png`, `reaper*.png`, `_*.bat`,
   `banner.png`, `icono.png`). ✅ verificado en `git status`.
3. **`Mockups_Etsy/build_all.ps1`** — reescrito **multi-pack**: `-Packs rock,gym,moto`.
   Gym/Moto ahora 100% por código (sin Figma; `build_pack_assets.ps1` ya estaba
   parametrizado por `-Pack`). Agrega guardas `Test-Path` + chequeo de audio. Sin args =
   solo Rock (sin regresión).

## Estado / pendiente de verificación
- **El render NO se verificó todavía.** El agente no puede ejecutar ImageMagick (crashea
  agent-spawned — ver memoria `magick-convert-crash.md`). Lo corre el usuario.
- El usuario chocó con la **execution policy** de PowerShell. Solución:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
  .\build_all.ps1 -Packs rock,gym,moto -Steps 1,2,3
  ```
  **Falta confirmar que la corrida del pipeline pasa limpia.**

## Próximo paso a decidir
Elegir por dónde empezar a **construir**: la plantilla de nutrición/fitness (#1, mayor
demanda) o el pack de SFX de guitarra (#2, menor esfuerzo, reusa los audios ya grabados en
`audios/`). Ninguno de los dos se empezó aún.

## Gotchas para el próximo agente
- No intentar renderizar PNG con ImageMagick desde el agente (crashea). El usuario corre los `.ps1`.
- No invocar `powershell.exe` vía Bash (hay regla de deny; el clasificador lo bloquea).
- Convenciones: español rioplatense/voseo, tono directo. Info personal del README no se toca sin confirmar.
- Memoria del proyecto en `C:\Users\Juan\.claude\projects\D--workspace-nicho\memory\`
  (índice en `MEMORY.md`): existen `magick-convert-crash.md` y `riffstream-pivot.md`.
- Plan de esta sesión: `C:\Users\Juan\.claude\plans\analiza-el-proyecto-nicho-dreamy-lynx.md`.
