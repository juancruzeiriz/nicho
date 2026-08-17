# Real Guitar Stream Alerts — doc interno del pack (producto #2)

> Estado: **Vol. 1 Expanded, PUBLICADO** — 66 sonidos reales en 10 tonos
> (clean, overdrive, fuzz, crunch, blues, rock, funk, delay, reverb,
> ambient/chords). Publicado en itch/Gumroad/Etsy el 17-ago-2026 via
> `RiffStream_Vol1_Expanded.zip`. Copy en `LISTINGS_Vol1_Expanded.md`.
> El roadmap "Vol. 2" de abajo quedó absorbido por esta expansión.

## Inventario

- **Selección curada para el comprador** (66 sonidos, todos los tonos):
  `audios/pack/`. Empaquetada en `RiffStream_Vol1_Expanded.zip` (no vía
  `build_sfx_pack.py` — ese script sigue armando el ZIP viejo de 6 sonidos,
  ver nota abajo).
- **Audio para el bot de marketing** (2 tomas por tono nuevo, para
  `products/Guitar_SFX_Pack/build_video_clips.py`): `audios/*.mp3` en la
  raíz (`alert-<tono>-01.mp3` / `-02.mp3`). Genera los Shorts 9:16 que
  postea el cron en la VM.

## Empaquetar (pendiente de actualizar)

```powershell
cd products\Guitar_SFX_Pack
.\build_sfx_pack.ps1                       # OJO: todavía arma el ZIP viejo de 6 sonidos
```

`build_sfx_pack.py` / `build_sfx_pack.ps1` no se actualizaron para los 66
sonidos — `RiffStream_Vol1_Expanded.zip` se armó aparte. Si hay que
re-generar el ZIP del comprador, actualizar `RENAMES` en
`build_sfx_pack.py` primero (hoy solo mapea los 6 originales).

## Canales y precios (post-expansión, 17-ago-2026)

| Canal | Formato | Precio |
|---|---|---|
| itch.io | PWYW | sugerido **$5** |
| Gumroad | fijo | **$9** |
| Etsy (listing 4520371511) | fijo | **$9** |

Copy vivo en `LISTINGS_Vol1_Expanded.md` (reemplaza a `LISTING_EN.md`, que
quedó desactualizado con el copy de 6 sonidos / 3 tonos).
