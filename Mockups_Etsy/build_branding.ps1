# ============================================================================
#  build_branding.ps1  —  Branding de la tienda Etsy (banner + icono)
# ----------------------------------------------------------------------------
#  Genera la identidad de tienda RiffStream:
#   - branding/banner_tienda_1200x300.png   (cabecera de la tienda Etsy)
#   - branding/icono_tienda_500x500.png     (avatar/icono de la tienda)
#
#  Uso:    .\build_branding.ps1
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

if (-not $OutDir) { $OutDir = Join-Path $repoRoot 'branding' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Paleta
$DARK    = '#0F0F12'
$GRAFITO = '#26262B'
$ROJO    = '#E63946'
$COBRE   = '#F4A259'
$WHITE   = '#F1FAEE'
$WHITE70 = 'rgba(241,250,238,0.70)'
$FONT_TITLE = 'Bahnschrift'
$FONT_BODY  = 'Arial'

# =============================== BANNER 1200x300 =============================
Write-Host '== Banner de tienda 1200x300 =='
$banner = Join-Path $OutDir 'banner_tienda_1200x300.png'
$b = @(
    '-size','1200x300',"gradient:$GRAFITO-$DARK",
    # barra de acento a la izquierda
    '-fill',$ROJO,'-draw','rectangle 0,0 14,300',
    # marca + tagline
    '-font',$FONT_TITLE,'-pointsize','110','-fill',$WHITE,'-gravity','West','-annotate','+70-20','RIFFSTREAM',
    '-font',$FONT_BODY,'-pointsize','30','-fill',$ROJO,'-gravity','West','-annotate','+74+70','OVERLAYS + ALERTAS DE GUITARRA REAL',
    '-font',$FONT_BODY,'-pointsize','24','-fill',$WHITE70,'-gravity','West','-annotate','+74+112','Para streamers  ·  Twitch  ·  Kick  ·  OBS  ·  en espanol'
)
# waveform decorativo a la derecha
$bx = 800
for ($k=0; $k -lt 16; $k++) {
    $hh = [int]((([Math]::Abs([Math]::Sin($k * 0.6))) * 80) + 14)
    $x1 = $bx + $k * 24
    $y1 = 150 - $hh
    $y2 = 150 + $hh
    $col = if ($k % 4 -eq 0) { $COBRE } else { $ROJO }
    $b += '-fill'; $b += $col; $b += '-draw'; $b += "roundrectangle $x1,$y1 $($x1+11),$y2 5,5"
}
$b += $banner
& $magick @b
Write-Host "   $banner OK"

# =============================== ICONO 500x500 ==============================
Write-Host '== Icono de tienda 500x500 =='
$icon = Join-Path $OutDir 'icono_tienda_500x500.png'
# fondo carbon + anillo de acento + pua roja + monograma RS
$ic = @(
    '-size','500x500',"xc:$DARK",
    # anillo de acento (circulo borde)
    '-fill','none','-stroke',$ROJO,'-strokewidth','12','-draw','circle 250,250 250,40',
    '-stroke','none',
    # pua de guitarra (silueta de acento) centrada
    '-fill',$ROJO,'-draw','path "M 250 150 C 318 150 360 184 360 240 C 360 300 296 372 250 384 C 204 372 140 300 140 240 C 140 184 182 150 250 150 Z"',
    # monograma RS en carbon sobre la pua
    '-font',$FONT_TITLE,'-pointsize','150','-fill',$DARK,'-gravity','Center','-annotate','+0-6','RS',
    $icon
)
& $magick @ic
Write-Host "   $icon OK"

Write-Host ''
Write-Host "Listo. Branding en $OutDir"
Get-ChildItem $OutDir -Filter '*.png' | Select-Object Name, @{N='KB';E={[int]($_.Length/1KB)}}
