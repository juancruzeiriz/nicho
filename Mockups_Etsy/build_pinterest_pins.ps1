# ============================================================================
#  build_pinterest_pins.ps1  —  Genera pines verticales 1000x1500 para Pinterest
# ----------------------------------------------------------------------------
#  Crea pines de diseno (texto grande sobre fondo oscuro de marca), uno por
#  fila del calendario (marketing/Pinterest_Calendario.md). No dependen de los
#  mockups: son piezas autonomas, listas para subir y enlazar al listing.
#
#  Salida: marketing/pins/pin_NN_*.png  (1000x1500, ratio 2:3)
#  Uso:    .\build_pinterest_pins.ps1
#  Requisito: ImageMagick (imagemagick.org).
# ============================================================================

param(
    [string]$OutDir = '',
    [string]$Magick = ''
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

function Find-Magick($explicit) {
    if ($explicit -and (Test-Path $explicit)) { return $explicit }
    $cmd = Get-Command magick -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'Apps\ImageMagick\magick.exe'),
        'C:\Program Files\ImageMagick-7.1.1-Q16\magick.exe',
        'C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe'
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        if ($base -and (Test-Path $base)) {
            $hit = Get-ChildItem -Path $base -Filter 'magick.exe' -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($hit) { return $hit.FullName }
        }
    }
    return $null
}
$magick = Find-Magick $Magick
if (-not $magick) { Write-Host 'ERROR: no encontre ImageMagick (magick.exe).' -ForegroundColor Red; exit 1 }

if (-not $OutDir) { $OutDir = Join-Path $repoRoot 'marketing\pins' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$tmp = Join-Path $OutDir '_tmp'
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

# Paleta
$DARK    = '#0F0F12'
$GRAFITO = '#26262B'
$ROJO    = '#E63946'
$COBRE   = '#F4A259'
$WHITE   = '#F1FAEE'
$WHITE85 = 'rgba(241,250,238,0.85)'
$WHITE70 = 'rgba(241,250,238,0.70)'
$FONT_TITLE = 'Bahnschrift'
$FONT_BODY  = 'Arial'

# --- Definicion de pines: titulo grande (sobre imagen), subtitulo, acento, audio
# acento: R = rojo (rock/general), O = naranja (gym/moto)
$pins = @(
    @{ h='OVERLAY ROCK + AUDIO DE GUITARRA REAL'; s='Twitch  -  Kick  -  OBS';                 a='R'; wf=$false },
    @{ h='PACK DE STREAM COMPLETO PARA OBS';      s='Overlay - Pantallas - Paneles - Audio';   a='R'; wf=$false },
    @{ h='EMPEZAMOS PRONTO ESTILO ROCK';          s='Pantalla de inicio para tu stream';       a='R'; wf=$false },
    @{ h='8 ICONOS ROCK  -  PNG + SVG';           s='Editables para tu overlay';               a='R'; wf=$false },
    @{ h='ALERTAS CON GUITARRA REAL';             s='Grabadas en vivo  -  3 variantes';        a='R'; wf=$true  },
    @{ h='PANELES PARA TU PERFIL DE TWITCH';      s='Discord - Instagram - Proximo stream';    a='R'; wf=$false },
    @{ h='YA VUELVO  (BRB)';                      s='Pantalla de pausa para tu stream';        a='R'; wf=$false },
    @{ h='OVERLAY TRANSPARENTE PARA OBS';         s='Marco de camara limpio';                  a='R'; wf=$false },
    @{ h='OFFLINE CON TUS REDES';                 s='Pantalla de cierre del canal';            a='R'; wf=$false },
    @{ h='KIT DE STREAM EN ESPANOL';              s='Twitch y Kick  -  descarga ya';           a='R'; wf=$false },
    @{ h='STREAMEAS TOCANDO LA VIOLA?';           s='Este pack es para vos';                   a='R'; wf=$false },
    @{ h='OVERLAY ROCK SOBRE GAMEPLAY';           s='Mira como queda en vivo';                 a='R'; wf=$false },
    @{ h='GUITARRA GRABADA EN VIVO';              s='El unico pack con audio real';            a='R'; wf=$true  },
    @{ h='STARTING  -  BRB  -  OFFLINE';          s='3 pantallas a juego';                     a='R'; wf=$false },
    @{ h='SETUP ROCKERO EN 10 MINUTOS';           s='Listo para salir en vivo';                a='R'; wf=$false },
    @{ h='OVERLAY DE GYM PARA STREAMERS';         s='Estetica de hierro, no kawaii';           a='O'; wf=$false },
    @{ h='CELEBRA CADA PR EN VIVO';               s='Con alertas de guitarra real';            a='O'; wf=$true  },
    @{ h='BUNDLE: ROCK + GYM + AHORRA';           s='Llevate los packs y pagas menos';         a='R'; wf=$false }
)

function New-Pin($index, $pin) {
    $accent = if ($pin.a -eq 'O') { $COBRE } else { $ROJO }
    $slug = ($pin.h -replace '[^a-zA-Z0-9]+','_').Trim('_').ToLower()
    if ($slug.Length -gt 28) { $slug = $slug.Substring(0,28) }
    $num = '{0:D2}' -f $index
    $out = Join-Path $OutDir ("pin_${num}_${slug}.png")

    # 1) base: degradado + barra superior + marca + barra CTA inferior
    $base = Join-Path $tmp ("base_$num.png")
    $b = @(
        '-size','1000x1500',"gradient:$GRAFITO-$DARK",
        '-fill',$accent,'-draw','rectangle 0,0 1000,12',
        '-font',$FONT_TITLE,'-pointsize','48','-fill',$accent,'-gravity','North','-annotate','+0+70','RIFFSTREAM',
        '-font',$FONT_BODY,'-pointsize','24','-fill',$WHITE70,'-gravity','North','-annotate','+0+148','OVERLAYS + ALERTAS DE GUITARRA REAL',
        '-fill',$accent,'-draw','rectangle 0,1380 1000,1500',
        '-font',$FONT_TITLE,'-pointsize','46','-fill',$DARK,'-gravity','South','-annotate','+0+42','EN ETSY  -  DESCARGA YA'
    )
    if ($pin.wf) {
        # waveform decorativo de acento, centrado horizontalmente cerca de y=1120
        $bx = 170
        for ($k=0; $k -lt 26; $k++) {
            $hh = [int]((([Math]::Abs([Math]::Sin($k * 0.55))) * 90) + 18)
            $x1 = $bx + $k * 25
            $y1 = 1140 - $hh
            $y2 = 1140 + $hh
            $b += '-fill'; $b += $accent; $b += '-draw'; $b += "roundrectangle $x1,$y1 $($x1+12),$y2 5,5"
        }
    }
    $b += $base
    & $magick @b

    # 2) titulo grande (caption auto-wrap)
    $head = Join-Path $tmp ("head_$num.png")
    & $magick -background none -fill $WHITE -font $FONT_TITLE -size 840x -pointsize 92 "caption:$($pin.h)" $head

    # 3) subtitulo
    $sub = Join-Path $tmp ("sub_$num.png")
    & $magick -background none -fill $accent -font $FONT_TITLE -size 760x -pointsize 40 -gravity Center "caption:$($pin.s)" $sub

    # 4) componer: titulo arriba del centro, subtitulo debajo
    & $magick $base `
        $head '-gravity' 'Center' '-geometry' '+0-150' '-composite' `
        $sub  '-gravity' 'Center' '-geometry' '+0+120' '-composite' `
        $out
    Write-Host "   $([IO.Path]::GetFileName($out)) OK"
}

Write-Host "magick : $magick"
Write-Host "out    : $OutDir"
Write-Host "== Generando $($pins.Count) pines =="
for ($i=0; $i -lt $pins.Count; $i++) { New-Pin ($i+1) $pins[$i] }

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
Write-Host ''
Write-Host "Listo. $($pins.Count) pines en $OutDir"
