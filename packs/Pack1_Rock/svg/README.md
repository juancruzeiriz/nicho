# Pack 1 (Rock) — fuentes vectoriales

## De dónde sale cada pieza

| Pieza | Origen | Cómo generarla |
|---|---|---|
| Overlay, 3 paneles, 3 pantallas | **ImageMagick** | Corré `Mockups_Etsy\build_pack_assets.ps1` (línea `rock`). No depende de Figma. |
| 8 íconos | **Estos SVG** (`icons/`) | El script los rasteriza a PNG 256×256. También editables en Figma/Inkscape. |

> A diferencia de Gym/Moto (que salieron del plugin de Figma), Rock se genera
> 100% con ImageMagick vía `build_pack_assets.ps1`, así el pipeline queda
> independiente de Figma.

## Íconos incluidos (color de acento Rock: `#E63946`)

1. `ic_01_pua.svg` — púa de guitarra
2. `ic_02_jack.svg` — plug/jack 1/4"
3. `ic_03_amplificador.svg` — amplificador
4. `ic_04_eq.svg` — ecualizador (faders)
5. `ic_05_microfono.svg` — micrófono
6. `ic_06_clavija.svg` — clavija de afinación
7. `ic_07_potenciometro.svg` — potenciómetro / perilla
8. `ic_08_cuerdas.svg` — cuerdas sobre el diapasón

## Cómo recolorear

El color está en los atributos `fill="#E63946"`. Para otra línea, buscá y
reemplazá el hex. El detalle interno usa `#1A1A1D` (carbón) para simular
recortes.

## Exportar a PNG 256×256 (a mano)

`magick -background none ic_01_pua.svg -resize 256x256 ic_01_pua.png`

(El script `build_pack_assets.ps1` ya hace esto por los 8 de una.)
