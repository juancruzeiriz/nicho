# ============================================================================
#  build_bundle_mockup.ps1  —  Mockup del BUNDLE (3 portadas + tabla de ahorro)
# ----------------------------------------------------------------------------
#  Arma una imagen 2000x2000 para el listing del bundle: collage de las 3
#  portadas (Rock / Gym / Moto) + tabla de precios con el ahorro.
#
#  Auto-detecta la portada de cada pack; si la de Rock todavia no se genero,
#  usa Mockups_Etsy\01_Portada.png como respaldo, o un placeholder con el nombre.
#
#  Salida: marketing/Bundle_Mockup.png
#  Uso:    .\build_bundle_mockup.ps1
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

if (-not $OutDir) { $OutDir = Join-Path $repoRoot 'marketing' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$tmp = Join-Path $OutDir '_tmp_bundle'
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

# --- Resolver portada de cada pack (con respaldos) --------------------------
function Resolve-Portada($candidates) {
    foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { return $c } }
    return $null
}
$rockPortada = Resolve-Portada @(
    (Join-Path $repoRoot 'packs\Pack1_Rock\RiffStream_Rock\Mockups\01_Portada.png'),
    (Join-Path $repoRoot 'Mockups_Etsy\01_Portada.png')
)
$gymPortada = Resolve-Portada @(
    (Join-Path $repoRoot 'packs\Pack2_Gym\RiffStream_Iron\Mockups\01_Portada.png'),
    (Join-Path $repoRoot 'packs\Pack2_Gym\Mockups\01_Portada.png')
)
$motoPortada = Resolve-Portada @(
    (Join-Path $repoRoot 'packs\Pack3_Moto\RiffStream_Ruta\Mockups\01_Portada.png'),
    (Join-Path $repoRoot 'packs\Pack3_Moto\Mockups\01_Portada.png')
)

$thumbW = 560
function Make-Thumb($src, $label, $accent, $idx) {
    $out = Join-Path $tmp ("thumb_$idx.png")
    if ($src) {
        & $magick $src -resize "${thumbW}x${thumbW}^" -gravity Center -extent "${thumbW}x${thumbW}" `
            -bordercolor '#3a3a40' -border 3 $out
    } else {
        & $magick -size "${thumbW}x${thumbW}" "xc:$GRAFITO" `
            -fill $accent -draw "rectangle 0,$($thumbW-10) $thumbW $thumbW" `
            -font $FONT_TITLE -pointsize 70 -fill $WHITE -gravity Center -annotate +0+0 $label `
            -bordercolor '#3a3a40' -border 3 $out
    }
    return $out
}
$tRock = Make-Thumb $rockPortada 'ROCK' $ROJO  'rock'
$tGym  = Make-Thumb $gymPortada  'GYM'  $COBRE 'gym'
$tMoto = Make-Thumb $motoPortada 'MOTO' $COBRE 'moto'

# --- Base + titulo ----------------------------------------------------------
$base = Join-Path $tmp 'base.png'
& $magick -size 2000x2000 "gradient:$GRAFITO-$DARK" `
    -fill $ROJO -draw 'rectangle 0,1990 2000,2000' `
    -font $FONT_TITLE -pointsize 130 -fill $WHITE -gravity North -annotate +0+90 'BUNDLE RIFFSTREAM' `
    -font $FONT_TITLE -pointsize 56 -fill $ROJO -gravity North -annotate +0+260 '3 PACKS  ·  1 PRECIO  ·  AHORRA HASTA 25%' `
    $base

# Posiciones de los 3 thumbs (fila centrada)
$gap = 80
$rowW = 3 * $thumbW + 2 * $gap   # 1840
$startX = [int](((2000 - $rowW) / 2))   # 80
$rowY = 470
$x0 = $startX
$x1 = $startX + $thumbW + $gap
$x2 = $startX + 2 * ($thumbW + $gap)

# Etiquetas de cada pack (debajo de cada thumb)
$labelY = $rowY + $thumbW + 24

# --- Panel de tabla de ahorro -----------------------------------------------
# (se dibuja sobre el base; las celdas se anotan con NorthWest)
$compose = @(
    $base,
    # thumbs
    $tRock, '-gravity','NorthWest','-geometry',"+$x0+$rowY",'-composite',
    $tGym,  '-gravity','NorthWest','-geometry',"+$x1+$rowY",'-composite',
    $tMoto, '-gravity','NorthWest','-geometry',"+$x2+$rowY",'-composite',
    # labels de packs
    '-font',$FONT_TITLE,'-pointsize','54','-fill',$ROJO, '-gravity','NorthWest','-annotate',"+$($x0+220)+$labelY",'ROCK',
    '-font',$FONT_TITLE,'-pointsize','54','-fill',$COBRE,'-gravity','NorthWest','-annotate',"+$($x1+230)+$labelY",'GYM',
    '-font',$FONT_TITLE,'-pointsize','54','-fill',$COBRE,'-gravity','NorthWest','-annotate',"+$($x2+215)+$labelY",'MOTO',
    # panel tabla
    '-fill',$GRAFITO,'-draw','roundrectangle 160,1300 1840,1900 18,18',
    '-fill',$ROJO,'-draw','rectangle 160,1300 1840,1316',
    '-font',$FONT_TITLE,'-pointsize','56','-fill',$WHITE,'-gravity','NorthWest','-annotate','+220+1350','COMBO',
    '-font',$FONT_TITLE,'-pointsize','56','-fill',$WHITE70,'-gravity','NorthWest','-annotate','+980+1350','INDIVIDUAL',
    '-font',$FONT_TITLE,'-pointsize','56','-fill',$WHITE,'-gravity','NorthWest','-annotate','+1320+1350','BUNDLE',
    '-font',$FONT_TITLE,'-pointsize','56','-fill',$ROJO,'-gravity','NorthWest','-annotate','+1620+1350','AHORRO',
    # fila DUO
    '-font',$FONT_TITLE,'-pointsize','64','-fill',$WHITE,'-gravity','NorthWest','-annotate','+220+1470','DUO  ·  Rock + Gym',
    '-font',$FONT_BODY,'-pointsize','58','-fill',$WHITE70,'-gravity','NorthWest','-annotate','+1010+1474','$24',
    '-font',$FONT_TITLE,'-pointsize','80','-fill',$COBRE,'-gravity','NorthWest','-annotate','+1330+1456','$18',
    '-font',$FONT_TITLE,'-pointsize','60','-fill',$ROJO,'-gravity','NorthWest','-annotate','+1620+1468','-25%',
    # fila TRIO
    '-font',$FONT_TITLE,'-pointsize','64','-fill',$WHITE,'-gravity','NorthWest','-annotate','+220+1650','TRIO  ·  Rock + Gym + Moto',
    '-font',$FONT_BODY,'-pointsize','58','-fill',$WHITE70,'-gravity','NorthWest','-annotate','+1010+1654','$36',
    '-font',$FONT_TITLE,'-pointsize','80','-fill',$COBRE,'-gravity','NorthWest','-annotate','+1330+1636','$28',
    '-font',$FONT_TITLE,'-pointsize','60','-fill',$ROJO,'-gravity','NorthWest','-annotate','+1620+1648','-22%',
    # firma
    '-font',$FONT_TITLE,'-pointsize','40','-fill',"${WHITE}AA",'-gravity','South','-annotate','+0+40','AUDIO DE GUITARRA REAL EN CADA PACK  ·  EDITABLE EN ESPANOL',
    (Join-Path $OutDir 'Bundle_Mockup.png')
)
& $magick @compose
Write-Host "   Bundle_Mockup.png OK"

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
Write-Host ''
Write-Host "Listo. Mockup del bundle en $(Join-Path $OutDir 'Bundle_Mockup.png')"
