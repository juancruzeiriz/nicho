# ============================================================================
#  build_pinterest_pins.ps1  —  Pines verticales 1000x1500 con imagen REAL
# ----------------------------------------------------------------------------
#  Cada pin = barra de marca + HERO (pieza de producto real: overlay sobre
#  escena, pantalla, mockup, o montage de iconos/pantallas) + titulo grande
#  + barra CTA. Mapeo pin->imagen segun marketing/Pinterest_Calendario.md.
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
$WHITE70 = 'rgba(241,250,238,0.70)'
$FONT_TITLE = 'Bahnschrift'
$FONT_BODY  = 'Arial'

# Rutas base de las piezas de producto
$rock   = Join-Path $repoRoot 'packs\Pack1_Rock\RiffStream_Rock'
$gym    = Join-Path $repoRoot 'packs\Pack2_Gym\RiffStream_Iron'
$bundle = Join-Path $repoRoot 'marketing\Bundle_Mockup.png'

# --- Definicion de pines ----------------------------------------------------
# t = tipo de hero: overlay | direct | micons | mscreens
# a = acento: R (rojo) | O (naranja)
$pins = @(
    @{ h='OVERLAY ROCK + AUDIO DE GUITARRA REAL'; s='Twitch  -  Kick  -  OBS';                a='R'; t='overlay';  src=(Join-Path $rock '01_Overlay\01_Overlay_Principal.png') },
    @{ h='PACK DE STREAM COMPLETO PARA OBS';      s='Overlay - Pantallas - Paneles - Audio';  a='R'; t='direct';   src=(Join-Path $rock 'Mockups\02_Que_Incluye.png') },
    @{ h='EMPEZAMOS PRONTO ESTILO ROCK';          s='Pantalla de inicio para tu stream';      a='R'; t='direct';   src=(Join-Path $rock '03_Pantallas\05_Starting_Soon.png') },
    @{ h='8 ICONOS ROCK  -  PNG + SVG';           s='Editables para tu overlay';              a='R'; t='micons';   src=(Join-Path $rock '04_Iconos') },
    @{ h='ALERTAS CON GUITARRA REAL';             s='Grabadas en vivo  -  3 variantes';       a='R'; t='direct';   src=(Join-Path $rock 'Mockups\08_Audio_Guitarra.png') },
    @{ h='PANELES PARA TU PERFIL DE TWITCH';      s='Discord - Instagram - Proximo stream';   a='R'; t='direct';   src=(Join-Path $rock 'Mockups\06_Paneles.png') },
    @{ h='YA VUELVO  (BRB)';                      s='Pantalla de pausa para tu stream';       a='R'; t='direct';   src=(Join-Path $rock '03_Pantallas\06_Be_Right_Back.png') },
    @{ h='OVERLAY TRANSPARENTE PARA OBS';         s='Marco de camara limpio';                 a='R'; t='overlay';  src=(Join-Path $rock '01_Overlay\01_Overlay_Principal.png') },
    @{ h='OFFLINE CON TUS REDES';                 s='Pantalla de cierre del canal';           a='R'; t='direct';   src=(Join-Path $rock '03_Pantallas\07_Offline.png') },
    @{ h='KIT DE STREAM EN ESPANOL';              s='Twitch y Kick  -  descarga ya';          a='R'; t='direct';   src=(Join-Path $rock 'Mockups\02_Que_Incluye.png') },
    @{ h='STREAMEAS TOCANDO LA VIOLA?';           s='Este pack es para vos';                  a='R'; t='direct';   src=(Join-Path $rock 'Mockups\01_Portada.png') },
    @{ h='OVERLAY ROCK SOBRE GAMEPLAY';           s='Mira como queda en vivo';                a='R'; t='overlay';  src=(Join-Path $rock '01_Overlay\01_Overlay_Principal.png') },
    @{ h='GUITARRA GRABADA EN VIVO';              s='El unico pack con audio real';           a='R'; t='direct';   src=(Join-Path $rock 'Mockups\08_Audio_Guitarra.png') },
    @{ h='STARTING  -  BRB  -  OFFLINE';          s='3 pantallas a juego';                    a='R'; t='mscreens'; src=@((Join-Path $rock '03_Pantallas\05_Starting_Soon.png'),(Join-Path $rock '03_Pantallas\06_Be_Right_Back.png'),(Join-Path $rock '03_Pantallas\07_Offline.png')) },
    @{ h='SETUP ROCKERO EN 10 MINUTOS';           s='Listo para salir en vivo';               a='R'; t='direct';   src=(Join-Path $rock 'Mockups\02_Que_Incluye.png') },
    @{ h='OVERLAY DE GYM PARA STREAMERS';         s='Estetica de hierro, no kawaii';          a='O'; t='direct';   src=(Join-Path $gym 'Mockups\01_Portada.png') },
    @{ h='CELEBRA CADA PR EN VIVO';               s='Con alertas de guitarra real';           a='O'; t='direct';   src=(Join-Path $gym 'Mockups\08_Audio_Guitarra.png') },
    @{ h='BUNDLE: ROCK + GYM + AHORRA';           s='Llevate los packs y pagas menos';        a='R'; t='direct';   src=$bundle }
)

# --- Hero: produce una imagen de producto encajada para la zona superior ----
function Build-Hero($pin, $accent, $out) {
    switch ($pin.t) {
        'overlay' {
            $scene = Join-Path $tmp 'h_scene.png'
            & $magick -size 900x506 "radial-gradient:#2a0e12-#0a0a0c" `
                -fill "${accent}33" -draw 'rectangle 0,360 900,506' -blur 0x30 $scene
            $ovs = Join-Path $tmp 'h_ov.png'
            & $magick $pin.src -resize 900x506 $ovs
            & $magick $scene $ovs -gravity Center -composite -bordercolor '#3a3a40' -border 3 $out
        }
        'micons' {
            $files = Get-ChildItem $pin.src -Filter '*.png' | Sort-Object Name | Select-Object -First 8
            $mArgs = @('montage')
            foreach ($f in $files) { $mArgs += $f.FullName }
            $mArgs += @('-tile','4x2','-geometry','185x185+16+16','-background',$GRAFITO,$out)
            & $magick @mArgs
        }
        'mscreens' {
            # filmstrip horizontal de las 3 pantallas (montage de oscuros se rompia)
            $parts = @()
            $k = 0
            foreach ($f in $pin.src) {
                $p = Join-Path $tmp ("ms_${k}.png")
                & $magick $f -resize 286x161 -bordercolor '#3a3a40' -border 3 $p
                $parts += $p; $k++
            }
            $aArgs = @('-background',$DARK)
            foreach ($p in $parts) { $aArgs += $p }
            $aArgs += @('+append',$out)
            & $magick @aArgs
        }
        default {  # direct
            & $magick $pin.src -resize 900x680 -bordercolor '#3a3a40' -border 3 $out
        }
    }
}

function New-Pin($index, $pin) {
    $accent = if ($pin.a -eq 'O') { $COBRE } else { $ROJO }
    $slug = ($pin.h -replace '[^a-zA-Z0-9]+','_').Trim('_').ToLower()
    if ($slug.Length -gt 28) { $slug = $slug.Substring(0,28) }
    $num = '{0:D2}' -f $index
    $out = Join-Path $OutDir ("pin_${num}_${slug}.png")

    # base: degradado + barra superior + marca + barra CTA inferior
    $base = Join-Path $tmp ("base_$num.png")
    & $magick -size 1000x1500 "gradient:$GRAFITO-$DARK" `
        -fill $accent -draw 'rectangle 0,0 1000,12' `
        -font $FONT_TITLE -pointsize 48 -fill $accent -gravity North -annotate +0+60 'RIFFSTREAM' `
        -font $FONT_BODY -pointsize 22 -fill $WHITE70 -gravity North -annotate +0+135 'OVERLAYS + ALERTAS DE GUITARRA REAL' `
        -fill $accent -draw 'rectangle 0,1380 1000,1500' `
        -font $FONT_TITLE -pointsize 46 -fill $DARK -gravity South -annotate +0+42 'EN ETSY  -  DESCARGA YA' `
        $base

    # hero (imagen de producto), encajado para no superar ~900x680
    $hero = Join-Path $tmp ("hero_$num.png")
    Build-Hero $pin $accent $hero
    $heroFit = Join-Path $tmp ("herofit_$num.png")
    & $magick $hero -resize 900x680 $heroFit
    # centrar el hero verticalmente en la zona [205..885]
    $heroOff = 205
    try {
        $hh = [int](& $magick identify -format '%h' $heroFit)
        $heroOff = [int](205 + (680 - $hh) / 2)
        if ($heroOff -lt 205) { $heroOff = 205 }
    } catch { $heroOff = 205 }

    # titulo grande + subtitulo
    $head = Join-Path $tmp ("head_$num.png")
    & $magick -background none -fill $WHITE -font $FONT_TITLE -size 860x -pointsize 70 "caption:$($pin.h)" $head
    $sub = Join-Path $tmp ("sub_$num.png")
    & $magick -background none -fill $accent -font $FONT_TITLE -size 780x -pointsize 34 -gravity Center "caption:$($pin.s)" $sub

    # componer: hero arriba, titulo y subtitulo abajo
    & $magick $base `
        $heroFit '-gravity' 'North'  '-geometry' "+0+$heroOff" '-composite' `
        $head    '-gravity' 'South' '-geometry' '+0+300' '-composite' `
        $sub     '-gravity' 'South' '-geometry' '+0+225' '-composite' `
        $out
    Write-Host "   $([IO.Path]::GetFileName($out)) OK"
}

Write-Host "magick : $magick"
Write-Host "out    : $OutDir"
Write-Host "== Generando $($pins.Count) pines con imagen real =="
for ($i=0; $i -lt $pins.Count; $i++) { New-Pin ($i+1) $pins[$i] }

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
Write-Host ''
Write-Host "Listo. $($pins.Count) pines en $OutDir"
