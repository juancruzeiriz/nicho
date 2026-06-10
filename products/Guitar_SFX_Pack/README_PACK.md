# Real Guitar Stream Alerts — doc interno del pack (producto #2)

> Estado: estructura lista, **faltan grabar 12 sonidos** para el pack completo.
> Los 6 existentes alcanzan para un soft-launch en itch.io (PWYW) si querés
> salir ya. Validación de demanda: GO (ver `VALIDACION.md`).

## Inventario actual (en `audios/`)

| Origen | Nombre en pack | Evento sugerido |
|---|---|---|
| alert-clean-1.mp3 | RGSP_Clean_Alert_01.mp3 | New follower |
| alert-clean-2.mp3 | RGSP_Clean_Alert_02.mp3 | New follower (alt) |
| alert-overdrive-1.mp3 | RGSP_Overdrive_Alert_01.mp3 | New sub |
| alert-overdrive-2.mp3 | RGSP_Overdrive_Alert_02.mp3 | Donation / cheer |
| alert-fuzz-1.mp3 | RGSP_Fuzz_Alert_01.mp3 | Raid |
| alert-fuzz-2.mp3 | RGSP_Fuzz_Alert_02.mp3 | Raid (alt) |

## Faltan grabar (objetivo: pack de 18)

Por la validación, la categoría organiza por **evento**, no por tono. Checklist:

- [ ] 2 stingers **clean** cortos (<2s) — follower
- [ ] 2 stingers **overdrive** cortos (<2s) — follower/sub
- [ ] 2 stingers **fuzz** cortos (<2s) — bits/cheer
- [ ] 1 riff **clean** 2-3s — donation
- [ ] 1 riff **overdrive** 2-3s — donation grande
- [ ] 1 riff **fuzz** 2-3s — host
- [ ] 2 transiciones 3-5s (subida limpia→fuzz) — BRB / Starting soon
- [ ] 2 raid stingers **fuzz** intensos 3-4s — raid

**Specs de export (Reaper):** master WAV 48 kHz / 24-bit, normalizado a
**−14 LUFS** integrado, true peak **−1 dBTP**, sin silencio inicial (>50 ms),
dejar la cola natural del ampli. Export adicional MP3 320 kbps CBR.
Nombrar: `RGSP_{Tono}_{Evento}_{NN}` (ej. `RGSP_Clean_Follower_01.wav`).

## Empaquetar

```powershell
cd products\Guitar_SFX_Pack
.\build_sfx_pack.ps1                       # tier standard, solo MP3
.\build_sfx_pack.ps1 -Tier commercial      # zip con licencia comercial
.\build_sfx_pack.ps1 -WavDir ..\..\audios_wav   # cuando existan los WAV
```

El script valida que estén los 6 audios (guardas tipo T3: si falta uno, corta
con error en vez de armar un ZIP incompleto).

## Canales y precios (de VALIDACION.md)

| Canal | Formato | Precio |
|---|---|---|
| itch.io | PWYW | piso **$5** |
| Gumroad | fijo | **$10** standard / **$18** commercial |
| Etsy (bonus: la tienda ya existe) | fijo | **$8** standard |

Copy listo en `LISTING_EN.md`. **Ojo:** el copy dice "18 sounds" — si el pack
final tiene otro número, actualizar listing + README del comprador.
