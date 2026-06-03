# Script para generar 8 mockups de Etsy para RiffStream con ImageMagick
# Cada mockup: 2000x2000 PNG, paleta rock (carbon #1A1A1D + rojo #E63946)
#
# NOTA: para packs nuevos (Gym, Moto) usá la versión generalizada y
# parametrizada: build_pack_mockups.ps1 (mismo directorio). Este archivo
# quedó como referencia del Pack 1. Las rutas ahora se auto-detectan.

$ErrorActionPreference = 'Stop'

# Rutas auto-detectadas (antes apuntaban a D:\ que ya no existe)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir
$magickCmd = Get-Command magick -ErrorAction SilentlyContinue
$magick = if ($magickCmd) { $magickCmd.Source }
          elseif (Test-Path 'C:\Program Files\ImageMagick-7.1.1-Q16\magick.exe') { 'C:\Program Files\ImageMagick-7.1.1-Q16\magick.exe' }
          else { 'D:\ImageMagick-7.1.1-Q16\magick.exe' }
$pack = Join-Path $repoRoot 'RiffStream_Pack'
$out = $scriptDir
$tmp = Join-Path $out '_tmp'
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

# Paleta
$BG_DARK = '#0F0F12'
$BG_MID = '#1A1A1D'
$BG_LIGHT = '#26262B'
$RED = '#E63946'
$WHITE = '#F1FAEE'
$ORANGE = '#F4A259'

$FONT_TITLE = 'Bahnschrift'
$FONT_BODY = 'Arial'

# Base 2000x2000 reutilizable: gradiente + marca de agua + linea roja inferior
function New-Base($path) {
    $a = @(
        '-size', '2000x2000', "gradient:$BG_LIGHT-$BG_DARK",
        '-fill', $RED, '-draw', 'rectangle 0,1990 2000,2000',
        '-font', $FONT_TITLE, '-pointsize', '28', '-fill', "${WHITE}66",
        '-gravity', 'SouthEast', '-annotate', '+50+30', 'RIFFSTREAM',
        $path
    )
    & $magick @a
}

Write-Host '== Build base template =='
$base = Join-Path $tmp 'base.png'
New-Base $base

# === MOCKUP 1 — Portada ===
Write-Host '== Mockup 1 — Portada =='
$scene = Join-Path $tmp 'scene.png'
& $magick -size 1700x956 'radial-gradient:#2a0e12-#0a0a0c' `
    -fill "${RED}33" -draw 'rectangle 0,650 1700,956' `
    -blur 0x40 $scene

$overlayScaled = Join-Path $tmp 'overlay_scaled.png'
& $magick (Join-Path $pack '01_Overlay\01_Overlay_Principal.png') -resize 1700x956 $overlayScaled

$sceneWithOverlay = Join-Path $tmp 'scene_overlay.png'
& $magick $scene $overlayScaled -composite $sceneWithOverlay

$sceneWithBorder = Join-Path $tmp 'scene_border.png'
& $magick $sceneWithOverlay -bordercolor '#3a3a40' -border 4 $sceneWithBorder

$portadaArgs = @(
    $base,
    $sceneWithBorder, '-gravity', 'North', '-geometry', '+0+380', '-composite',
    '-font', $FONT_TITLE, '-pointsize', '180', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+90', 'RIFFSTREAM',
    '-font', $FONT_TITLE, '-pointsize', '60', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+290', 'PACK PARA STREAMERS ROCKEROS',
    '-font', $FONT_TITLE, '-pointsize', '70', '-fill', $WHITE,
    '-gravity', 'South', '-annotate', '+0+260', 'OVERLAY  ·  3 PANTALLAS  ·  3 PANELES  ·  8 ICONOS',
    '-font', $FONT_TITLE, '-pointsize', '90', '-fill', $RED,
    '-gravity', 'South', '-annotate', '+0+150', '+ 3 ALERTAS DE GUITARRA REAL',
    (Join-Path $out '01_Portada.png')
)
& $magick @portadaArgs
Write-Host '   01_Portada.png OK'

# === Helper: dibujar un card con titulo, imagen y caption (para mockups 3-5) ===
function Build-ScreenMockup($title, $caption, $screenPath, $outPath) {
    # Escalar la pantalla 1920x1080 a 1700x956
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

# === MOCKUP 2 — Que incluye ===
Write-Host '== Mockup 2 — Que incluye =='
# Thumbs en grilla 3 columnas x 2 filas: Overlay, Pantallas, Paneles, Iconos, Audios, "+ guia"
# Cada celda 540x540 con asset thumb + label
$cellW = 540
$cellH = 540
$gridX = 145  # margen horizontal
$gridY = 480  # offset desde arriba (debajo del titulo)
$gapX = 50
$gapY = 50

# Pre-build cards: cada uno con fondo $BG_MID y borde sutil
function New-Card($contentPath, $label, $outCard, $contentResize = '380x380') {
    $cardBg = Join-Path $tmp ('cardbg_' + [Guid]::NewGuid().Guid.Substring(0,8) + '.png')
    & $magick -size "${cellW}x${cellH}" "xc:#1F1F23" `
        -fill $RED -draw "rectangle 0,535 $cellW $cellH" `
        $cardBg
    if ($contentPath) {
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

$card1 = Join-Path $tmp 'card1.png'; New-Card (Join-Path $pack '01_Overlay\01_Overlay_Principal.png') '1 OVERLAY 1920x1080' $card1
$card2 = Join-Path $tmp 'card2.png'; New-Card (Join-Path $pack '03_Pantallas\05_Starting_Soon.png') '3 PANTALLAS FULL HD' $card2
$card3 = Join-Path $tmp 'card3.png'; New-Card (Join-Path $pack '02_Paneles\02_Panel_Discord.png') '3 PANELES PARA PERFIL' $card3 '400x213'
$card4 = Join-Path $tmp 'card4.png'; New-Card (Join-Path $pack '04_Iconos\ic_pua.png') '8 ICONOS ROCK PNG+SVG' $card4

# Card 5: 3 alertas audio (placeholder con waveform)
$wf = Join-Path $tmp 'wf.png'
& $magick -size 400x150 "xc:#1F1F23" `
    -fill none -strokewidth 6 -stroke $RED `
    -draw 'polyline 20,75 60,40 100,90 140,30 180,100 220,40 260,80 300,50 340,90 380,60' `
    $wf
$card5 = Join-Path $tmp 'card5.png'; New-Card $wf '3 ALERTAS GUITARRA REAL' $card5 '440x165'

# Card 6: guia OBS (texto only)
$card6 = Join-Path $tmp 'card6.png'; New-Card $null 'GUIA OBS EN ESPANOL' $card6

$queIncluyeArgs = @(
    $base,
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+200', 'QUE INCLUYE',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+390', 'TODO LO QUE NECESITAS PARA SALIR EN VIVO',
    # Fila 1
    $card1, '-geometry', "+$gridX+$gridY", '-composite',
    $card2, '-geometry', "+$($gridX + $cellW + $gapX)+$gridY", '-composite',
    $card3, '-geometry', "+$($gridX + 2 * ($cellW + $gapX))+$gridY", '-composite',
    # Fila 2
    $card4, '-geometry', "+$gridX+$($gridY + $cellH + $gapY)", '-composite',
    $card5, '-geometry', "+$($gridX + $cellW + $gapX)+$($gridY + $cellH + $gapY)", '-composite',
    $card6, '-geometry', "+$($gridX + 2 * ($cellW + $gapX))+$($gridY + $cellH + $gapY)", '-composite',
    (Join-Path $out '02_Que_Incluye.png')
)
& $magick @queIncluyeArgs
Write-Host '   02_Que_Incluye.png OK'

# === MOCKUP 3, 4, 5 — Pantallas ===
Write-Host '== Mockup 3 — Starting Soon =='
Build-ScreenMockup 'STARTING SOON' 'PANTALLA DE INICIO DE STREAM' `
    (Join-Path $pack '03_Pantallas\05_Starting_Soon.png') `
    (Join-Path $out '03_Starting_Soon.png')
Write-Host '   03_Starting_Soon.png OK'

Write-Host '== Mockup 4 — Be Right Back =='
Build-ScreenMockup 'BE RIGHT BACK' 'PANTALLA DE PAUSA DURANTE EL STREAM' `
    (Join-Path $pack '03_Pantallas\06_Be_Right_Back.png') `
    (Join-Path $out '04_Be_Right_Back.png')
Write-Host '   04_Be_Right_Back.png OK'

Write-Host '== Mockup 5 — Offline =='
Build-ScreenMockup 'OFFLINE' 'PANTALLA DE CIERRE DEL CANAL' `
    (Join-Path $pack '03_Pantallas\07_Offline.png') `
    (Join-Path $out '05_Offline.png')
Write-Host '   05_Offline.png OK'

# === MOCKUP 6 — Paneles ===
Write-Host '== Mockup 6 — Paneles =='
# Mock perfil twitch: 3 paneles verticales con thumbnail de overlay arriba
$panelDisc = Join-Path $pack '02_Paneles\02_Panel_Discord.png'
$panelInsta = Join-Path $pack '02_Paneles\03_Panel_Instagram.png'
$panelSig = Join-Path $pack '02_Paneles\04_Panel_Siguiente.png'

# Cada panel original 300x160, lo escalo a 1200x640 (4x)
$pd = Join-Path $tmp 'pd.png'; & $magick $panelDisc -resize 1200x640 $pd
$pi = Join-Path $tmp 'pi.png'; & $magick $panelInsta -resize 1200x640 $pi
$ps = Join-Path $tmp 'ps.png'; & $magick $panelSig -resize 1200x640 $ps

$panelesArgs = @(
    $base,
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+150', 'PANELES PARA TU PERFIL',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+340', '3 PANELES LISTOS  ·  DISCORD  ·  INSTAGRAM  ·  SIGUIENTE STREAM',
    $pd, '-gravity', 'Center', '-geometry', '+0-310', '-composite',
    $pi, '-gravity', 'Center', '-geometry', '+0+90', '-composite',
    $ps, '-gravity', 'Center', '-geometry', '+0+490', '-composite',
    (Join-Path $out '06_Paneles.png')
)
& $magick @panelesArgs
Write-Host '   06_Paneles.png OK'

# === MOCKUP 7 — Set de iconos ===
Write-Host '== Mockup 7 — Set de iconos =='
$icons = @(
    @('pua', 'PUA'),
    @('clavija', 'CLAVIJA'),
    @('potenciometro', 'POT'),
    @('microfono', 'MIC'),
    @('jack', 'JACK'),
    @('ecualizador', 'EQ'),
    @('cuerdas', 'CUERDAS'),
    @('amplificador', 'AMP')
)

# Grilla 4 cols x 2 filas, cada icono en celda de ~400x500 (icono 280x280 + label)
$iconCellW = 400
$iconCellH = 480
$iconStartX = 100  # left margin -> (2000 - 4*400)/2 = 200, pero quiero un poco mas de aire = 100
$iconStartY = 520

# Generar cards de iconos
$iconCards = @()
foreach ($i in $icons) {
    $name = $i[0]
    $label = $i[1]
    $cardPath = Join-Path $tmp ("icard_$name.png")
    $iconPath = Join-Path $pack "04_Iconos\ic_$name.png"
    $iconThumb = Join-Path $tmp ("ithumb_$name.png")
    & $magick $iconPath -resize 280x280 $iconThumb
    & $magick -size "${iconCellW}x${iconCellH}" 'xc:none' `
        $iconThumb -gravity North -geometry +0+50 -composite `
        -font $FONT_TITLE -pointsize 44 -fill $WHITE -gravity South -annotate +0+30 $label `
        $cardPath
    $iconCards += $cardPath
}

$iconArgs = @(
    $base,
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE,
    '-gravity', 'North', '-annotate', '+0+150', '8 ICONOS ROCK',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED,
    '-gravity', 'North', '-annotate', '+0+340', 'PNG + SVG  ·  EDITABLES  ·  TRANSPARENTES'
)
$idx = 0
for ($row = 0; $row -lt 2; $row++) {
    for ($col = 0; $col -lt 4; $col++) {
        $x = $iconStartX + $col * $iconCellW
        $y = $iconStartY + $row * $iconCellH
        $iconArgs += $iconCards[$idx]
        $iconArgs += '-geometry'
        $iconArgs += "+$x+$y"
        $iconArgs += '-composite'
        $idx++
    }
}
$iconArgs += (Join-Path $out '07_Iconos.png')
& $magick @iconArgs
Write-Host '   07_Iconos.png OK'

# === MOCKUP 8 — Diferenciador audio ===
Write-Host '== Mockup 8 — Diferenciador audio =='
# Waveform grande estilizado + 3 botones (LIMPIA / OVERDRIVE / FUZZ) + icono pua/amp
$bigWf = Join-Path $tmp 'big_wf.png'
# Waveform sintetico con puntos
$drawCmd = 'stroke-linecap round'
# Genero waveform como una serie de barras verticales
$wfCanvasArgs = @('-size', '1600x400', 'xc:none', '-fill', $RED, '-stroke', $RED)
$barCount = 80
$barWidth = 14
$barGap = ((1600 - $barCount * $barWidth) / ($barCount - 1))
for ($i = 0; $i -lt $barCount; $i++) {
    # Amplitud variable (simulada): seno con ruido
    $h = [Math]::Abs([Math]::Sin($i * 0.3) * 130) + (Get-Random -Minimum 20 -Maximum 80)
    $x = [int]($i * ($barWidth + $barGap))
    $y1 = [int](200 - $h / 2)
    $y2 = [int](200 + $h / 2)
    $wfCanvasArgs += '-draw'
    $wfCanvasArgs += "roundrectangle $x,$y1 $($x + $barWidth),$y2 4,4"
}
$wfCanvasArgs += $bigWf
& $magick @wfCanvasArgs

# Tres "botones" de alerta tipo: LIMPIA / OVERDRIVE / FUZZ
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
    (Join-Path $out '08_Audio_Guitarra.png')
)
& $magick @audioArgs
Write-Host '   08_Audio_Guitarra.png OK'

Write-Host ''
Write-Host 'Listo. Output:'
Get-ChildItem $out -Filter '*.png' | Select-Object Name, @{N='Size (KB)';E={[int]($_.Length/1KB)}}
