# Cómo generar todos los assets (un comando)

> Los PNG (overlay, paneles, pantallas, mockups, pines, branding, bundle) se
> generan con **ImageMagick** vía PowerShell. Corré esto en una terminal
> PowerShell normal (no dentro del agente, donde ImageMagick crashea):

```powershell
cd D:\workspace\nicho\Mockups_Etsy
.\build_all.ps1
```

Eso genera, en orden:

1. **Pack Rock** — overlay + 3 paneles + 3 pantallas + 8 íconos
   (`packs\Pack1_Rock\RiffStream_Rock\`), replicando el overlay enriquecido del
   plugin pero 100% con ImageMagick (sin Figma).
2. **Mockups de Etsy** del Pack Rock (`...\Mockups\`).
3. **ZIP** del Pack Rock listo para subir (`packs\Pack1_Rock\RiffStream_Rock.zip`).
4. **~18 pines de Pinterest** verticales 1000×1500 (`marketing\pins\`).
5. **Branding** de tienda: banner 1200×300 + ícono 500×500 (`branding\`).
6. **Mockup del bundle**: collage de las 3 portadas + tabla de ahorro
   (`marketing\Bundle_Mockup.png`).

## Audio (opcional)

Si ya grabaste las 3 alertas (limpia / overdrive / fuzz), metelas en el ZIP:

```powershell
.\build_all.ps1 -RockAudioDir "D:\workspace\nicho\_audio_rock"
```

Sin `-RockAudioDir`, el ZIP se arma igual con un placeholder avisando que
faltan los audios.

## Correr una sola pieza

Cada script anda solo:

```powershell
.\build_pack_assets.ps1 -Pack rock      # solo los assets del pack
.\build_pinterest_pins.ps1              # solo los pines
.\build_branding.ps1                    # solo el branding
.\build_bundle_mockup.ps1              # solo el mockup del bundle
```

## Revisá a ojo

Como el Pack Rock se arma con ImageMagick replicando lo que el plugin hacía en
Figma, **mirá el overlay y las pantallas** después de generarlos: si algún
texto quedó corrido o un color no pega, avisá y ajusto las coordenadas en
`build_pack_assets.ps1`.
