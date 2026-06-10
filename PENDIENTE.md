# PENDIENTE — RiffStream (actualizado 2026-06-07)

> Archivo de trabajo — NO commitear. Estado real verificado archivo por archivo.
> Leyenda: 🔴 solo vos · 🔵 lo puedo hacer yo · 🟣 vos+yo · ⛔ bloqueado (motivo)

---

## 0. Estado real (verificado 2026-06-07)

| Pack | Assets | 8 Mockups | ZIP | Audio en ZIP | Borrador Etsy |
|------|:--:|:--:|:--:|:--:|:--:|
| **1 Rock** | ✅ | ✅ | ✅ | ✅ 6 tomas | ✅ título+desc+tags+$12 |
| **2 Gym** (Iron) | ✅ | ✅ | ✅ | ❌ placeholder | ✅ título+desc+tags+$12 |
| **3 Moto** (Ruta) | ✅ | ✅ | ✅ | ❌ placeholder | ✅ título+desc+tags+$12 |

- **Tienda Etsy:** 3 borradores activos a $12 · mensaje de bienvenida ✅ · política de devoluciones: no aplica (digital).
- **Marketing:** 18/30 pines PNG en `marketing/pins/` · script `build_pinterest_pins.ps1` tiene 30 definidos (usá `-Start 19` para generar solo los nuevos con ImageMagick) · guion video ✅ `marketing/Video_Proceso_Guion.md`.
- **Git:** commit `9ec3fe5` listo localmente → falta `git push origin master` (ejecutar en tu PowerShell).

---

## 1. Pack 1 Rock — publicar  ⬅️ PRIORIDAD MÁXIMA

| # | Tarea | Quién | Nota |
|---|-------|:--:|------|
| 1.1 | Subir 8 fotos al borrador (`packs/Pack1_Rock/RiffStream_Rock/Mockups/` 01→08) | 🔴 ⛔ | file_upload solo acepta sesión compartida; arrastrá vos |
| 1.2 | Subir ZIP `packs/Pack1_Rock/RiffStream_Rock.zip` como archivo digital | 🔴 ⛔ | ídem |
| 1.3 | **Publicar** y copiar la URL del listing | 🔴 | acción pública irreversible |

---

## 2. Marketing Pack 1 (después de publicar, necesita URL activa)

| # | Tarea | Quién | Nota |
|---|-------|:--:|------|
| 2.1 | Pinterest: subir pines 1-15 (2-3/día) enlazando al listing | 🔴 ⛔ | upload de archivos + necesita URL viva |
| 2.2 | Reddit: POST 1 + POST 3 (`marketing/Reddit_Posts.md`), días distintos | 🔴 | leer reglas del sub, no pegar link directo |

---

## 3. Pack 2 Gym — publicar (Semana 4)

| # | Tarea | Quién | Nota |
|---|-------|:--:|------|
| 3.1 | Meter audio al ZIP de Gym | 🔴 | `.\build_pack_zip.ps1 -AudioDir ..\audios` desde `Mockups_Etsy/` |
| 3.2 | Subir fotos (`packs/Pack2_Gym/RiffStream_Iron/Mockups/`) + ZIP + publicar | 🔴 ⛔ | ídem 1.1-1.3 |
| 3.3 | Pinterest 16-25 + Reddit POST 4 (Gym) | 🔴 | |

---

## 4. Pack 3 Moto — opcional, baja prioridad

| # | Tarea | Quién | Nota |
|---|-------|:--:|------|
| 4.1 | Meter audio al ZIP de Moto | 🔴 | igual que Gym |
| 4.2 | Subir fotos (`packs/Pack3_Moto/RiffStream_Ruta/Mockups/`) + ZIP + publicar | 🔴 ⛔ | demanda baja (README) — hacelo después de validar Rock+Gym |

---

## 5. Pinterest pins 19-30 (imágenes físicas)

| # | Tarea | Quién | Nota |
|---|-------|:--:|------|
| 5.1 | Generar PNGs de pins 19-30 | 🔴 | `.\build_pinterest_pins.ps1 -Start 19` — necesita ImageMagick funcionando |
| 5.2 | Subir a Pinterest (2-3/día) enlazando al listing publicado | 🔴 | |

---

## 6. Bundle + optimización (Semana 5, tras primeras ventas)

| # | Tarea | Quién | Nota |
|---|-------|:--:|------|
| 6.1 | Bundle Rock+Gym a $18 (`marketing/Bundle_Listing.md`) | 🔵+🔴 | texto yo, fotos+publish vos |
| 6.2 | SEO: eRank, ajustar 2-3 tags (`seo/Keywords_Tags.md` §5) | 🔴 | con datos reales de impresiones |
| 6.3 | Etsy Stats: ver qué pack convierte mejor | 🔴 | |

---

## 7. Higiene del repo (decisiones tuyas)

| Archivo sin trackear | Sugerencia |
|---|---|
| `audios/` (6 MP3) | ¿commitear? son ~2,5 MB binarios. O agregar a `.gitignore` |
| `banner.png`, `icono.png` | ¿reemplazan a `branding/`? decidir |
| `FIGMA.png`, `reaper.png`, `reaper2.png` | screenshots — borrar o `.gitignore` |
| `_jtest.bat`, `_xln_junction.bat` | scratch — borrar o ignorar |
| `.claude/settings.local.json` | NO versionar (ya está en CLAUDE.md) |
| `PENDIENTE.md` | NO commitear (scratch) |

---

## ▶️ Próximo paso inmediato para vos

```
# 1. Push del último commit
git push origin master

# 2. Agregar audio al ZIP de Gym (desde Mockups_Etsy/)
.\build_pack_zip.ps1 -AudioDir ..\audios

# 3. En Etsy: abrir borrador Rock → fotos → ZIP → Publicar
#    Copiar URL → úsala en Pinterest y Reddit
```
