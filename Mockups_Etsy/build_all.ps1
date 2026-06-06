# ============================================================================
#  build_all.ps1  —  Corre TODA la pipeline de assets en orden (UN comando)
# ----------------------------------------------------------------------------
#  Genera, de punta a punta:
#    1. Assets del Pack Rock (overlay + paneles + pantallas + iconos)
#    2. Mockups de Etsy del Pack Rock
#    3. ZIP final del Pack Rock (para subir como descarga)
#    4. Pines de Pinterest (~18, verticales 1000x1500)
#    5. Branding de tienda (banner 1200x300 + icono 500x500)
#    6. Mockup del bundle (3 portadas + tabla de ahorro)
#
#  USO (desde una terminal PowerShell normal, donde ImageMagick funciona):
#       cd D:\workspace\nicho\Mockups_Etsy
#       .\build_all.ps1
#
#  Audio (opcional): si ya grabaste los MP3, pasalos para meterlos en el ZIP:
#       .\build_all.ps1 -RockAudioDir "D:\workspace\nicho\_audio_rock"
#
#  Requisito: ImageMagick instalado (imagemagick.org). Cada sub-script
#  autodetecta magick.exe.
# ============================================================================

param(
    [string]$RockAudioDir = ''
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $here

$rockPack = Join-Path $repoRoot 'packs\Pack1_Rock\RiffStream_Rock'
$rockSvg  = Join-Path $repoRoot 'packs\Pack1_Rock\svg\icons'

function Step($n, $msg) { Write-Host ""; Write-Host "######## [$n] $msg" -ForegroundColor Cyan }

Step 1 'Assets del Pack Rock (ImageMagick, sin Figma)'
& (Join-Path $here 'build_pack_assets.ps1') -Pack rock -PackDir $rockPack -IconsSvgDir $rockSvg

Step 2 'Mockups de Etsy del Pack Rock'
& (Join-Path $here 'build_pack_mockups.ps1') `
    -PackDir $rockPack `
    -OutDir  (Join-Path $rockPack 'Mockups') `
    -Brand   'RIFFSTREAM' `
    -Subtitle 'PACK PARA STREAMERS DE ROCK' `
    -Accent  '#E63946'

Step 3 'ZIP final del Pack Rock'
$zipArgs = @{
    PackDir     = $rockPack
    IconsSvgDir = $rockSvg
}
if ($RockAudioDir) { $zipArgs.AudioDir = $RockAudioDir }
& (Join-Path $here 'build_pack_zip.ps1') @zipArgs

Step 4 'Pines de Pinterest'
& (Join-Path $here 'build_pinterest_pins.ps1')

Step 5 'Branding de tienda (banner + icono)'
& (Join-Path $here 'build_branding.ps1')

Step 6 'Mockup del bundle'
& (Join-Path $here 'build_bundle_mockup.ps1')

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " TODO LISTO. Revisa:" -ForegroundColor Green
Write-Host "  - Pack Rock : $rockPack"
Write-Host "  - Mockups   : $(Join-Path $rockPack 'Mockups')"
Write-Host "  - ZIP       : $(Join-Path (Split-Path $rockPack -Parent) 'RiffStream_Rock.zip')"
Write-Host "  - Pines     : $(Join-Path $repoRoot 'marketing\pins')"
Write-Host "  - Branding  : $(Join-Path $repoRoot 'branding')"
Write-Host "  - Bundle    : $(Join-Path $repoRoot 'marketing\Bundle_Mockup.png')"
Write-Host "==================================================" -ForegroundColor Green
