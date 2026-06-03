# ============================================================================
#  build_pack_mockups.ps1  —  Generador de mockups de Etsy REUSABLE
# ----------------------------------------------------------------------------
#  Versión generalizada de _build_mockups.ps1. Sirve para CUALQUIER pack
#  RiffStream (Rock / Gym / Moto), no solo el primero.
#
#  Cambios clave vs. el original:
#   - Rutas auto-detectadas (no más D:\ hardcodeado que ya no existe).
#   - magick.exe auto-detectado (PATH o instalaciones comunes).
#   - Marca, subtítulo y color de acento como PARÁMETROS.
#
#  Uso:
#    .\build_pack_mockups.ps1 -PackDir "..\packs\Pack2_Gym\RiffStream_Iron" `
#                             -OutDir  "..\packs\Pack2_Gym\Mockups" `
#                             -Brand "RIFFSTREAM IRON" `
#                             -Subtitle "PACK PARA STREAMERS DE GYM" `
#                             -Accent "#F4A259"
#
#  Requisito: ImageMagick instalado (imagemagick.org). Si no está, el script
#  avisa y termina sin romper nada.
# ============================================================================

param(
    [string]$PackDir,
    [string]$OutDir,
    [string]$Brand    = 'RIFFSTREAM',
    [string]$Subtitle = 'PACK PARA STREAMERS',
    [string]$Accent   = '#E63946',
    [string]$Magick   = ''
)

$ErrorActionPreference = 'Stop'

# --- Raíz del repo = carpeta padre de este script (Mockups_Etsy) -------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

# --- Defaults relativos si no se pasaron parámetros -------------------------
if (-not $PackDir) { $PackDir = Join-Path $repoRoot 'RiffStream_Pack' }
if (-not $OutDir)  { $OutDir  = $scriptDir }

# --- Auto-detectar magick.exe -----------------------------------------------
function Find-Magick($explicit) {
    if ($explicit -and (Test-Path $explicit)) { return $explicit }
    $cmd = Get-Command magick -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'Apps\ImageMagick\magick.exe'),
        'C:\Program Files\ImageMagick-7.1.1-Q16\magick.exe',
        'C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe',
        'D:\ImageMagick-7.1.1-Q16\magick.exe'
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    # Búsqueda amplia en Program Files (por si la versión cambió)
    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        if ($base -and (Test-Path $base)) {
            $hit = Get-ChildItem -Path $base -Filter 'magick.exe' -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($hit) { return $hit.FullName }
        }
    }
    return $null
}

$magick = Find-Magick $Magick
if (-not $magick) {
    Write-Host 'ERROR: no encontre ImageMagick (magick.exe).' -ForegroundColor Red
    Write-Host 'Instalalo desde https://imagemagick.org y volve a correr el script,'
    Write-Host 'o pasá la ruta con -Magick "C:\ruta\a\magick.exe".'
    exit 1
}
if (-not (Test-Path $PackDir)) {
    Write-Host "ERROR: no existe la carpeta del pack: $PackDir" -ForegroundColor Red
    exit 1
}

Write-Host "magick : $magick"
Write-Host "pack   : $PackDir"
Write-Host "out    : $OutDir"
Write-Host "brand  : $Brand   accent: $Accent"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$tmp = Join-Path $OutDir '_tmp'
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

# --- Paleta (base fija + acento parametrizado) ------------------------------
$BG_DARK  = '#0F0F12'
$BG_LIGHT = '#26262B'
$RED      = $Accent      # color de acento de la línea
$WHITE    = '#F1FAEE'

$FONT_TITLE = 'Bahnschrift'   # sustituto de Bebas Neue
$FONT_BODY  = 'Arial'

# --- Base reutilizable: gradiente + marca de agua + línea de acento ---------
function New-Base($path) {
    $a = @(
        '-size', '2000x2000', "gradient:$BG_LIGHT-$BG_DARK",
        '-fill', $RED, '-draw', 'rectangle 0,1990 2000,2000',
        '-font', $FONT_TITLE, '-pointsize', '28', '-fill', "${WHITE}66",
        '-gravity', 'SouthEast', '-annotate', '+50+30', $Brand,
        $path
    )
    & $magick @a
}

Write-Host '== Build base template =='
$base = Join-Path $tmp 'base.png'
New-Base $base

# === MOCKUP 1 — Portada ======================================================
Write-Host '== Mockup 1 - Portada =='
$overlaySrc = Join-Path $PackDir '01_Overlay\01_Overlay_Principal.png'
$scene = Join-Path $tmp 'scene.png'
& $magick -size 1700x956 'radial-gradient:#2a0e12-#0a0a0c' `
    -fill "${RED}33" -draw 'rectangle 0,650 1700,956' `
    -blur 0x40 $scene

$overlayScaled = Join-Path $tmp 'overlay_scaled.png'
& $magick $overlaySrc -resize 1700x956 $overlayScaled

$sceneWithOverlay = Join-Path $tmp 'scene_overlay.png'
& $magick $scene $overlayScaled -composite $sceneWithOverlay

$sceneWithBorder = Join-Path $tmp 'scene_border.png'
& $magick $sceneWithOverlay -bordercolor '#3a3a40' -border 4 $sceneWithBorder

$portadaArgs = @(
    $base,
    $sceneWithBorder, '-gravity', 'North', '-geometry', '+0+380', '-composite',
    '-font', $FONT_TITLE, '-pointsize', '180', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+90', $Brand,
    '-font', $FONT_TITLE, '-pointsize', '60', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+290', $Subtitle,
    '-font', $FONT_TITLE, '-pointsize', '70', '-fill', $WHITE,
    '-gravity', 'South', '-annotate', '+0+260', 'OVERLAY  ·  3 PANTALLAS  ·  3 PANELES  ·  8 ICONOS',
    '-font', $FONT_TITLE, '-pointsize', '90', '-fill', $RED,
    '-gravity', 'South', '-annotate', '+0+150', '+ 3 ALERTAS DE GUITARRA REAL',
    (Join-Path $OutDir '01_Portada.png')
)
& $magick @portadaArgs
Write-Host '   01_Portada.png OK'

# === Helper pantallas (mockups 3-5) =========================================
function Build-ScreenMockup($title, $caption, $screenPath, $outPath) {
    $scaled = Join-Path $tmp ('scr_' + [IO.Path]::GetFileNameWithoutExtension($screenPath) + '.png')
    & $magick $screenPath -resize 1700x956 $scaled
    $bordered = Join-Path $tmp ('scrb_' + [IO.Path]::GetFileNameWithoutExtension($screenPath) + '.png')
    & $magick $scaled -bordercolor '#3a3a40' -border 4 $bordered

    $a = @(
        $base,
        $bordered, '-gravity', 'Center', '-geometry', '+0+0', '-composite',
        '-font', $FONT_TITLE, '-pointsize', '140', '-fill', $WHITE,
        '-gravity', 'North', '-annotate', '+0+150', $title,
        '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED,
        '-gravity', 'North', '-annotate', '+0+320', $caption,
        '-font', $FONT_TITLE, '-pointsize', '54', '-fill', "${WHITE}AA",
        '-gravity', 'South', '-annotate', '+0+200', 'INCLUIDO EN EL PACK · 1920x1080  ·  PNG',
        $outPath
    )
    & $magick @a
}

# === MOCKUP 2 — Que incluye =================================================
Write-Host '== Mockup 2 - Que incluye =='
$cellW = 540; $cellH = 540
$gridX = 145; $gridY = 480
$gapX = 50;   $gapY = 50

function New-Card($contentPath, $label, $outCard, $contentResize = '380x380') {
    $cardBg = Join-Path $tmp ('cardbg_' + [Guid]::NewGuid().Guid.Substring(0,8) + '.png')
    & $magick -size "${cellW}x${cellH}" "xc:#1F1F23" `
        -fill $RED -draw "rectangle 0,535 $cellW $cellH" `
        $cardBg
    if ($contentPath -and (Test-Path $contentPath)) {
        $thumb = Join-Path $tmp ('thumb_' + [Guid]::NewGuid().Guid.Substring(0,8) + '.png')
        & $magick $contentPath -resize $contentResize $thumb
        & $magick $cardBg $thumb -gravity North -geometry +0+50 -composite `
            -font $FONT_TITLE -pointsize 38 -fill $WHITE -gravity South -annotate +0+50 $label `
            $outCard
    } else {
        & $magick $cardBg `
            -font $FONT_TITLE -pointsize 38 -fill $WHITE -gravity Center -annotate +0+0 $label `
            $outCard
    }
}

$card1 = Join-Path $tmp 'card1.png'; New-Card (Join-Path $PackDir '01_Overlay\01_Overlay_Principal.png') '1 OVERLAY 1920x1080' $card1
$card2 = Join-Path $tmp 'card2.png'; New-Card (Join-Path $PackDir '03_Pantallas\05_Starting_Soon.png') '3 PANTALLAS FULL HD' $card2
$card3 = Join-Path $tmp 'card3.png'; New-Card (Join-Path $PackDir '02_Paneles\02_Panel_Discord.png') '3 PANELES PARA PERFIL' $card3 '400x213'
$card4 = Join-Path $tmp 'card4.png'; New-Card (Join-Path $PackDir '04_Iconos\ic_01.png') '8 ICONOS PNG+SVG' $card4

$wf = Join-Path $tmp 'wf.png'
& $magick -size 400x150 "xc:#1F1F23" `
    -fill none -strokewidth 6 -stroke $RED `
    -draw 'polyline 20,75 60,40 100,90 140,30 180,100 220,40 260,80 300,50 340,90 380,60' `
    $wf
$card5 = Join-Path $tmp 'card5.png'; New-Card $wf '3 ALERTAS GUITARRA REAL' $card5 '440x165'
$card6 = Join-Path $tmp 'card6.png'; New-Card $null 'GUIA OBS EN ESPANOL' $card6

$queIncluyeArgs = @(
    $base,
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+200', 'QUE INCLUYE',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+390', 'TODO LO QUE NECESITAS PARA SALIR EN VIVO',
    '-gravity', 'NorthWest',
    $card1, '-geometry', "+$gridX+$gridY", '-composite',
    $card2, '-geometry', "+$($gridX + $cellW + $gapX)+$gridY", '-composite',
    $card3, '-geometry', "+$($gridX + 2 * ($cellW + $gapX))+$gridY", '-composite',
    $card4, '-geometry', "+$gridX+$($gridY + $cellH + $gapY)", '-composite',
    $card5, '-geometry', "+$($gridX + $cellW + $gapX)+$($gridY + $cellH + $gapY)", '-composite',
    $card6, '-geometry', "+$($gridX + 2 * ($cellW + $gapX))+$($gridY + $cellH + $gapY)", '-composite',
    (Join-Path $OutDir '02_Que_Incluye.png')
)
& $magick @queIncluyeArgs
Write-Host '   02_Que_Incluye.png OK'

# === MOCKUP 3, 4, 5 — Pantallas =============================================
Write-Host '== Mockup 3 - Starting Soon =='
Build-ScreenMockup 'STARTING SOON' 'PANTALLA DE INICIO DE STREAM' `
    (Join-Path $PackDir '03_Pantallas\05_Starting_Soon.png') `
    (Join-Path $OutDir '03_Starting_Soon.png')

Write-Host '== Mockup 4 - Be Right Back =='
Build-ScreenMockup 'BE RIGHT BACK' 'PANTALLA DE PAUSA DURANTE EL STREAM' `
    (Join-Path $PackDir '03_Pantallas\06_Be_Right_Back.png') `
    (Join-Path $OutDir '04_Be_Right_Back.png')

Write-Host '== Mockup 5 - Offline =='
Build-ScreenMockup 'OFFLINE' 'PANTALLA DE CIERRE DEL CANAL' `
    (Join-Path $PackDir '03_Pantallas\07_Offline.png') `
    (Join-Path $OutDir '05_Offline.png')

# === MOCKUP 6 — Paneles =====================================================
Write-Host '== Mockup 6 - Paneles =='
$pd = Join-Path $tmp 'pd.png'; & $magick (Join-Path $PackDir '02_Paneles\02_Panel_Discord.png')   -resize 1200x640 $pd
$pi = Join-Path $tmp 'pi.png'; & $magick (Join-Path $PackDir '02_Paneles\03_Panel_Instagram.png') -resize 1200x640 $pi
$ps = Join-Path $tmp 'ps.png'; & $magick (Join-Path $PackDir '02_Paneles\04_Panel_Siguiente.png') -resize 1200x640 $ps

$panelesArgs = @(
    $base,
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+150', 'PANELES PARA TU PERFIL',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+340', '3 PANELES LISTOS  ·  DISCORD  ·  INSTAGRAM  ·  SIGUIENTE STREAM',
    $pd, '-gravity', 'Center', '-geometry', '+0-310', '-composite',
    $pi, '-gravity', 'Center', '-geometry', '+0+90', '-composite',
    $ps, '-gravity', 'Center', '-geometry', '+0+490', '-composite',
    (Join-Path $OutDir '06_Paneles.png')
)
& $magick @panelesArgs
Write-Host '   06_Paneles.png OK'

# === MOCKUP 7 — Set de iconos ===============================================
Write-Host '== Mockup 7 - Set de iconos =='
$iconCellW = 400; $iconCellH = 480
$iconStartX = 200; $iconStartY = 520

$iconCards = @()
$iconFiles = Get-ChildItem -Path (Join-Path $PackDir '04_Iconos') -Filter '*.png' -ErrorAction SilentlyContinue | Select-Object -First 8
$slot = 0
foreach ($icf in $iconFiles) {
    $label = (([IO.Path]::GetFileNameWithoutExtension($icf.Name)) -replace '^ic[_-]?\d+[_-]?', '').ToUpper()
    $cardPath = Join-Path $tmp ("icard_$slot.png")
    $iconThumb = Join-Path $tmp ("ithumb_$slot.png")
    & $magick $icf.FullName -resize 280x280 $iconThumb
    & $magick -size "${iconCellW}x${iconCellH}" 'xc:none' `
        $iconThumb -gravity North -geometry +0+50 -composite `
        -font $FONT_TITLE -pointsize 44 -fill $WHITE -gravity South -annotate +0+30 $label `
        $cardPath
    $iconCards += $cardPath
    $slot++
}

$iconArgs = @(
    $base,
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+150', '8 ICONOS',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+340', 'PNG + SVG  ·  EDITABLES  ·  TRANSPARENTES',
    '-gravity', 'NorthWest'
)
$idx = 0
for ($row = 0; $row -lt 2; $row++) {
    for ($col = 0; $col -lt 4; $col++) {
        if ($idx -lt $iconCards.Count) {
            $x = $iconStartX + $col * $iconCellW
            $y = $iconStartY + $row * $iconCellH
            $iconArgs += $iconCards[$idx]
            $iconArgs += '-geometry'
            $iconArgs += "+$x+$y"
            $iconArgs += '-composite'
        }
        $idx++
    }
}
$iconArgs += (Join-Path $OutDir '07_Iconos.png')
& $magick @iconArgs
Write-Host '   07_Iconos.png OK'

# === MOCKUP 8 — Diferenciador audio =========================================
Write-Host '== Mockup 8 - Diferenciador audio =='
$bigWf = Join-Path $tmp 'big_wf.png'
$wfCanvasArgs = @('-size', '1600x400', 'xc:none', '-fill', $RED, '-stroke', $RED)
$barCount = 80; $barWidth = 14
$barGap = ((1600 - $barCount * $barWidth) / ($barCount - 1))
for ($i = 0; $i -lt $barCount; $i++) {
    $h = [Math]::Abs([Math]::Sin($i * 0.3) * 130) + (Get-Random -Minimum 20 -Maximum 80)
    $x = [int]($i * ($barWidth + $barGap))
    $y1 = [int](200 - $h / 2)
    $y2 = [int](200 + $h / 2)
    $wfCanvasArgs += '-draw'
    $wfCanvasArgs += "roundrectangle $x,$y1 $($x + $barWidth),$y2 4,4"
}
$wfCanvasArgs += $bigWf
& $magick @wfCanvasArgs

function New-AlertButton($label, $sub, $out) {
    $a = @(
        '-size', '520x200', "xc:#1F1F23",
        '-fill', $RED, '-draw', 'rectangle 0,0 520,8',
        '-font', $FONT_TITLE, '-pointsize', '70', '-fill', $WHITE,
        '-gravity', 'Center', '-annotate', '+0-20', $label,
        '-font', $FONT_TITLE, '-pointsize', '32', '-fill', "${WHITE}99",
        '-gravity', 'Center', '-annotate', '+0+50', $sub,
        $out
    )
    & $magick @a
}
$btnA = Join-Path $tmp 'btn_a.png'; New-AlertButton 'LIMPIA' 'GUITARRA CLEAN' $btnA
$btnB = Join-Path $tmp 'btn_b.png'; New-AlertButton 'OVERDRIVE' 'CLON KLON BOUTIQUE' $btnB
$btnC = Join-Path $tmp 'btn_c.png'; New-AlertButton 'FUZZ' 'GERMANIO VINTAGE' $btnC

$audioArgs = @(
    $base,
    '-font', $FONT_TITLE, '-pointsize', '150', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+150', 'ALERTAS DE GUITARRA',
    '-font', $FONT_TITLE, '-pointsize', '150', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+310', 'REAL',
    '-font', $FONT_TITLE, '-pointsize', '45', '-fill', "${WHITE}CC",
    '-gravity', 'North', '-annotate', '+0+490', 'GRABADAS EN VIVO  ·  PEDALERA BOUTIQUE  ·  3 VARIANTES',
    $bigWf, '-gravity', 'Center', '-geometry', '+0-100', '-composite',
    $btnA, '-gravity', 'Center', '-geometry', '-560+300', '-composite',
    $btnB, '-gravity', 'Center', '-geometry', '+0+300', '-composite',
    $btnC, '-gravity', 'Center', '-geometry', '+560+300', '-composite',
    '-font', $FONT_TITLE, '-pointsize', '40', '-fill', "${WHITE}80",
    '-gravity', 'South', '-annotate', '+0+200', 'ARTEMIS OVERDRIVE  ·  FUZZ GERMANIO  ·  ARTURIA MINIFUSE 1',
    (Join-Path $OutDir '08_Audio_Guitarra.png')
)
& $magick @audioArgs
Write-Host '   08_Audio_Guitarra.png OK'

Write-Host ''
Write-Host 'Listo. Output:'
Get-ChildItem $OutDir -Filter '*.png' | Select-Object Name, @{N='Size (KB)';E={[int]($_.Length/1KB)}}
