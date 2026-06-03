# ============================================================================
#  build_pack_zip.ps1  —  Arma el ZIP final del comprador para un pack
# ----------------------------------------------------------------------------
#  Toma una carpeta de pack ensamblada y produce el ZIP listo para subir a
#  Etsy como descarga digital. INCLUYE: overlay, paneles, pantallas, iconos
#  (PNG + SVG), audios y el LEEME. EXCLUYE la carpeta Mockups (esos van como
#  fotos del listing, no dentro del producto).
#
#  Uso:
#    .\build_pack_zip.ps1 `
#       -PackDir     "..\packs\Pack2_Gym\RiffStream_Iron" `
#       -IconsSvgDir "..\packs\Pack2_Gym\svg\icons" `
#       -AudioDir    "..\_audio_gym"      # opcional, donde estan los MP3
#
#  Si no pasas -AudioDir (o esta vacio), genera el ZIP igual pero con un
#  placeholder en 05_Alertas_Audio avisando que faltan los audios.
# ============================================================================

param(
    [Parameter(Mandatory=$true)][string]$PackDir,
    [string]$IconsSvgDir = '',
    [string]$AudioDir    = '',
    [string]$ZipPath     = ''
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $PackDir)) { Write-Host "ERROR: no existe PackDir: $PackDir" -ForegroundColor Red; exit 1 }

$packName = Split-Path $PackDir -Leaf
if (-not $ZipPath) { $ZipPath = Join-Path (Split-Path $PackDir -Parent) ($packName + '.zip') }

# Carpeta de staging temporal (estructura limpia para el comprador)
$stage = Join-Path $env:TEMP ('zip_' + $packName + '_' + [Guid]::NewGuid().Guid.Substring(0,6))
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# 1) Carpetas de assets (sin Mockups)
foreach ($sub in '01_Overlay','02_Paneles','03_Pantallas') {
    $src = Join-Path $PackDir $sub
    if (Test-Path $src) { Copy-Item $src (Join-Path $stage $sub) -Recurse -Force }
    else { Write-Host "  aviso: falta $sub en el pack" -ForegroundColor Yellow }
}

# 2) Iconos: PNG del pack + SVG editables
$iconDst = Join-Path $stage '04_Iconos'
New-Item -ItemType Directory -Force -Path $iconDst | Out-Null
$iconPng = Join-Path $PackDir '04_Iconos'
if (Test-Path $iconPng) { Get-ChildItem $iconPng -Filter '*.png' | Copy-Item -Destination $iconDst -Force }
if ($IconsSvgDir -and (Test-Path $IconsSvgDir)) { Get-ChildItem $IconsSvgDir -Filter '*.svg' | Copy-Item -Destination $iconDst -Force }

# 3) LEEME
$leeme = Join-Path $PackDir 'LEEME_Primero.txt'
if (Test-Path $leeme) { Copy-Item $leeme (Join-Path $stage 'LEEME_Primero.txt') -Force }
else { Write-Host "  aviso: falta LEEME_Primero.txt en el pack" -ForegroundColor Yellow }

# 4) Audio
$audioDst = Join-Path $stage '05_Alertas_Audio'
New-Item -ItemType Directory -Force -Path $audioDst | Out-Null
$audioFiles = @()
if ($AudioDir -and (Test-Path $AudioDir)) {
    $audioFiles = Get-ChildItem $AudioDir -Include '*.mp3','*.wav' -Recurse -ErrorAction SilentlyContinue
}
if ($audioFiles.Count -gt 0) {
    $audioFiles | Copy-Item -Destination $audioDst -Force
    Write-Host "  ok  $($audioFiles.Count) archivos de audio incluidos"
} else {
    Set-Content -Path (Join-Path $audioDst 'FALTAN_LOS_AUDIOS.txt') -Encoding UTF8 `
        -Value 'Pone aca los 3 MP3 (limpia / overdrive / fuzz) y volve a generar el ZIP con -AudioDir.'
    Write-Host "  AVISO: sin audios -> ZIP con placeholder. Graba los MP3 y regenera." -ForegroundColor Yellow
}

# 5) Comprimir
if (Test-Path $ZipPath) { Remove-Item -LiteralPath $ZipPath -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $ZipPath -Force
Remove-Item -LiteralPath $stage -Recurse -Force

$kb = [int]((Get-Item $ZipPath).Length / 1KB)
Write-Host ""
Write-Host "ZIP listo: $ZipPath  ($kb KB)" -ForegroundColor Green
Write-Host "Contenido:"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($ZipPath)
$zip.Entries | ForEach-Object { Write-Host ("  - " + $_.FullName) }
$zip.Dispose()
