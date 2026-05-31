# FIX v2: corrige bug de gravity heredado entre annotate y composite.
$ErrorActionPreference = 'Stop'
$magick = 'D:\ImageMagick-7.1.1-Q16\magick.exe'
$pack = 'D:\proyectos-personales\nicho\RiffStream_Pack'
$out = 'D:\proyectos-personales\nicho\Mockups_Etsy'
$tmp = Join-Path $out '_tmp'

$BG_DARK = '#0F0F12'
$BG_MID = '#1A1A1D'
$BG_LIGHT = '#26262B'
$RED = '#E63946'
$WHITE = '#F1FAEE'
$ORANGE = '#F4A259'
$FONT_TITLE = 'Bahnschrift'
$FONT_BODY = 'Arial'

$base = Join-Path $tmp 'base.png'

# ============== MOCKUP 2 — Que Incluye ==============
Write-Host '== Mockup 2 — Que Incluye (FIX gravity) =='

$cellW = 540
$cellH = 540
$gridX = 145
$gridY = 510
$gapX = 50
$gapY = 60

function New-Card($contentPath, $label, $outCard, $contentResize = '380x380') {
    $cardBg = Join-Path $tmp ('cardbg_' + [Guid]::NewGuid().Guid.Substring(0,8) + '.png')
    & $magick -size "${cellW}x${cellH}" 'xc:#1F1F23' `
        -fill $RED -draw "rectangle 0,535 $cellW $cellH" `
        $cardBg
    if ($contentPath) {
        $thumb = Join-Path $tmp ('thumb_' + [Guid]::NewGuid().Guid.Substring(0,8) + '.png')
        & $magick $contentPath -resize $contentResize $thumb
        & $magick $cardBg $thumb -gravity North -geometry +0+60 -composite `
            -gravity South -font $FONT_TITLE -pointsize 38 -fill $WHITE -annotate +0+50 $label `
            $outCard
    } else {
        & $magick $cardBg `
            -gravity Center -font $FONT_TITLE -pointsize 42 -fill $WHITE -annotate +0+0 $label `
            $outCard
    }
}

$card1 = Join-Path $tmp 'card1.png'; New-Card (Join-Path $pack '01_Overlay\01_Overlay_Principal.png') '1 OVERLAY 1920x1080' $card1
$card2 = Join-Path $tmp 'card2.png'; New-Card (Join-Path $pack '03_Pantallas\05_Starting_Soon.png') '3 PANTALLAS FULL HD' $card2
$card3 = Join-Path $tmp 'card3.png'; New-Card (Join-Path $pack '02_Paneles\02_Panel_Discord.png') '3 PANELES PARA PERFIL' $card3 '440x235'
$card4 = Join-Path $tmp 'card4.png'; New-Card (Join-Path $pack '04_Iconos\ic_pua.png') '8 ICONOS ROCK PNG+SVG' $card4

# Waveform card 5
$wf = Join-Path $tmp 'wf.png'
$wfArgs = @('-size', '440x180', 'xc:none', '-fill', $RED)
$barCount = 30
$barW = 8
$barGap = ((440 - $barCount * $barW) / ($barCount - 1))
for ($i = 0; $i -lt $barCount; $i++) {
    $h = [Math]::Abs([Math]::Sin($i * 0.4) * 60) + (Get-Random -Minimum 15 -Maximum 50)
    $x = [int]($i * ($barW + $barGap))
    $y1 = [int](90 - $h / 2)
    $y2 = [int](90 + $h / 2)
    $wfArgs += '-draw'
    $wfArgs += "roundrectangle $x,$y1 $($x + $barW),$y2 3,3"
}
$wfArgs += $wf
& $magick @wfArgs

$card5 = Join-Path $tmp 'card5.png'; New-Card $wf '3 ALERTAS GUITARRA REAL' $card5 '440x180'
$card6 = Join-Path $tmp 'card6.png'; New-Card $null 'GUIA OBS EN ESPANOL' $card6

# Final compose con gravity NorthWest explicito para composites
$queIncluyeArgs = @(
    $base,
    '-gravity', 'North',
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE, '-annotate', '+0+200', 'QUE INCLUYE',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED, '-annotate', '+0+390', 'TODO LO QUE NECESITAS PARA SALIR EN VIVO',
    '-gravity', 'NorthWest',
    $card1, '-geometry', "+$gridX+$gridY", '-composite',
    $card2, '-geometry', "+$($gridX + $cellW + $gapX)+$gridY", '-composite',
    $card3, '-geometry', "+$($gridX + 2 * ($cellW + $gapX))+$gridY", '-composite',
    $card4, '-geometry', "+$gridX+$($gridY + $cellH + $gapY)", '-composite',
    $card5, '-geometry', "+$($gridX + $cellW + $gapX)+$($gridY + $cellH + $gapY)", '-composite',
    $card6, '-geometry', "+$($gridX + 2 * ($cellW + $gapX))+$($gridY + $cellH + $gapY)", '-composite',
    (Join-Path $out '02_Que_Incluye.png')
)
& $magick @queIncluyeArgs
Write-Host '   02_Que_Incluye.png OK'

# ============== MOCKUP 7 — Iconos ==============
Write-Host '== Mockup 7 — Iconos (FIX gravity) =='
$icons = @(
    @('pua', 'PUA'),
    @('clavija', 'CLAVIJA'),
    @('potenciometro', 'POTE'),
    @('microfono', 'MICRO'),
    @('jack', 'JACK'),
    @('ecualizador', 'EQ'),
    @('cuerdas', 'CUERDAS'),
    @('amplificador', 'AMP')
)

$iconCellW = 420
$iconCellH = 480
$iconStartX = 160
$iconStartY = 560

$iconCards = @()
foreach ($i in $icons) {
    $name = $i[0]
    $label = $i[1]
    $cardPath = Join-Path $tmp ("icard_$name.png")
    $iconPath = Join-Path $pack "04_Iconos\ic_$name.png"
    $iconThumb = Join-Path $tmp ("ithumb_$name.png")
    & $magick $iconPath -resize 280x280 $iconThumb
    & $magick -size "${iconCellW}x${iconCellH}" 'xc:none' `
        $iconThumb -gravity North -geometry +0+40 -composite `
        -gravity South -font $FONT_TITLE -pointsize 44 -fill $WHITE -annotate +0+40 $label `
        $cardPath
    $iconCards += $cardPath
}

$iconArgs = @(
    $base,
    '-gravity', 'North',
    '-font', $FONT_TITLE, '-pointsize', '160', '-fill', $WHITE, '-annotate', '+0+150', '8 ICONOS ROCK',
    '-font', $FONT_TITLE, '-pointsize', '50', '-fill', $RED, '-annotate', '+0+340', 'PNG + SVG  .  EDITABLES  .  TRANSPARENTES',
    '-gravity', 'NorthWest'
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

# ============== MOCKUP 6 — Paneles (re-verificar) — ya estaba ok pero revalido ==============
# Skip, ya esta bueno

# ============== MOCKUP 8 — Audio (re-verificar) ==============
# El audio tiene composites usando gravity Center explicito por item, deberia estar ok. Skip.

Write-Host ''
Write-Host 'Fix v2 aplicado.'
Get-ChildItem $out -Filter '*.png' | Sort-Object Name | Select-Object Name, @{N='Size (KB)';E={[int]($_.Length/1KB)}}
