# ============================================================================
#  build_sfx_pack.ps1  —  Arma el ZIP del comprador para Real Guitar Stream Alerts
# ----------------------------------------------------------------------------
#  Copia los audios de audios/ con los nombres de venta (RGSP_*), agrega el
#  README del comprador y la licencia del tier, y comprime. Si falta algun
#  audio corta con error (guardas tipo T3: nunca armar un ZIP incompleto).
#
#  Uso (desde esta carpeta):
#    .\build_sfx_pack.ps1                          # tier standard, solo MP3
#    .\build_sfx_pack.ps1 -Tier commercial         # licencia comercial
#    .\build_sfx_pack.ps1 -WavDir ..\..\audios_wav # incluye WAV masters
# ============================================================================

param(
    [string]$AudioDir = (Join-Path $PSScriptRoot '..\..\audios'),
    [ValidateSet('standard','commercial')][string]$Tier = 'standard',
    [string]$WavDir = '',
    [string]$OutDir = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

# Mapa de renombre: origen (audios/) -> nombre de venta.
# Al grabar los sonidos nuevos (ver README_PACK.md), agregarlos aca.
$renames = [ordered]@{
    'alert-clean-1.mp3'     = 'RGSP_Clean_Alert_01.mp3'
    'alert-clean-2.mp3'     = 'RGSP_Clean_Alert_02.mp3'
    'alert-overdrive-1.mp3' = 'RGSP_Overdrive_Alert_01.mp3'
    'alert-overdrive-2.mp3' = 'RGSP_Overdrive_Alert_02.mp3'
    'alert-fuzz-1.mp3'      = 'RGSP_Fuzz_Alert_01.mp3'
    'alert-fuzz-2.mp3'      = 'RGSP_Fuzz_Alert_02.mp3'
}

# Guardas: todos los origenes y los archivos de soporte tienen que existir
$missing = @()
foreach ($src in $renames.Keys) {
    if (-not (Test-Path (Join-Path $AudioDir $src))) { $missing += $src }
}
foreach ($f in 'README_BUYER_EN.txt','LICENSE_Standard.txt','LICENSE_Commercial.txt') {
    if (-not (Test-Path (Join-Path $PSScriptRoot $f))) { $missing += $f }
}
if ($missing.Count -gt 0) {
    Write-Host "ERROR: faltan archivos, no se arma el ZIP:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

# Staging limpio
$stage = Join-Path $env:TEMP ('sfx_' + [Guid]::NewGuid().Guid.Substring(0,6))
$mp3Dst = Join-Path $stage '01_Alerts_MP3'
New-Item -ItemType Directory -Force -Path $mp3Dst | Out-Null

foreach ($kv in $renames.GetEnumerator()) {
    Copy-Item (Join-Path $AudioDir $kv.Key) (Join-Path $mp3Dst $kv.Value) -Force
}
Write-Host "  ok  $($renames.Count) MP3 renombrados"

if ($WavDir -and (Test-Path $WavDir)) {
    $wavDst = Join-Path $stage '02_Alerts_WAV'
    New-Item -ItemType Directory -Force -Path $wavDst | Out-Null
    $wavs = Get-ChildItem $WavDir -Filter '*.wav'
    $wavs | Copy-Item -Destination $wavDst -Force
    Write-Host "  ok  $($wavs.Count) WAV masters incluidos"
}

Copy-Item (Join-Path $PSScriptRoot 'README_BUYER_EN.txt') (Join-Path $stage 'README.txt') -Force
$lic = if ($Tier -eq 'commercial') { 'LICENSE_Commercial.txt' } else { 'LICENSE_Standard.txt' }
Copy-Item (Join-Path $PSScriptRoot $lic) (Join-Path $stage 'LICENSE.txt') -Force

# Comprimir
$ZipPath = Join-Path $OutDir ("RealGuitar_StreamAlerts_" + $Tier + ".zip")
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
