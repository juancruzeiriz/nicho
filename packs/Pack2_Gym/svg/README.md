# Pack 2 (Gym) — fuentes vectoriales

## De dónde sale cada pieza

| Pieza | Origen | Cómo generarla |
|---|---|---|
| Overlay, 3 paneles, 3 pantallas | **Plugin de Figma** | Corré `riffstream-plugin-packs/` con `BUILD = ["gym"]`. Genera los Frames editables; exportás PNG. |
| 8 íconos | **Estos SVG** (`icons/`) | Importalos a Figma (arrastrar el .svg al lienzo) o usalos directo. Exportá PNG 256×256. |

> División a propósito: el plugin arma las piezas con texto/layout; los íconos
> son vectores finos que rinden mejor dibujados a mano como SVG. Figma importa
> SVG nativo y quedan 100% editables (color, tamaño).

## Íconos incluidos (color de acento Gym: `#F4A259`)

1. `ic_01_mancuerna.svg`
2. `ic_02_barra.svg`
3. `ic_03_kettlebell.svg`
4. `ic_04_cronometro.svg`
5. `ic_05_llama.svg`
6. `ic_06_botella.svg`
7. `ic_07_pulso.svg`
8. `ic_08_trofeo.svg`

## Cómo recolorear

El color está en los atributos `fill="#F4A259"`. Para otra línea (ej. Rock
rojo `#E63946`), buscá y reemplazá el hex, o cambiá el color en Figma tras
importar. El detalle interno usa `#1A1A1D` (carbón) para simular recortes.

## Exportar a PNG 256×256

- En Figma: seleccionás el ícono → panel Export → PNG → 1x (256×256) → Export.
- O cuando tengas ImageMagick:
  `magick -background none ic_01_mancuerna.svg -resize 256x256 ic_01_mancuerna.png`
