# ============================================================================
#  from_figma_export.ps1  —  De export de Figma a mockups de Etsy, en 1 paso
# ----------------------------------------------------------------------------
#  Toma una carpeta con los PNG exportados desde Figma (nombrados por frame,
#  ej. "Gym_01_Overlay_Principal.png"), los reorganiza en la estructura que
#  espera build_pack_mockups.ps1, copia los iconos, y genera los 8 mockups.
#
#  Uso tipico:
#    .\from_figma_export.ps1 `
#        -ExportDir "F:\workspace\nicho\_figma_export" `
#        -PackDir   "F:\workspace\nicho\packs\Pack2_Gym\RiffStream_Iron" `
#        -Brand "RIFFSTREAM IRON" -Subtitle "PACK PARA STREAMERS DE GYM" `
#        -Accent "#F4A259" `
#        -IconsDir "F:\workspace\nicho\packs\Pack2_Gym\svg\icons"
#
#  El matching de archivos es por SUFIJO, asi que ignora el prefijo Gym_/Moto_.
# ============================================================================

param(
    [Parameter(Mandatory=$true)][string]$ExportDir,
    [Parameter(Mandatory=$true)][string]$PackDir,
    [string]$Brand    = 'RIFFSTREAM',
    [string]$Subtitle = 'PACK PARA STREAMERS',
    [string]$Accent   = '#E63946',
    [string]$IconsDir = ''
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ExportDir)) { Write-Host "ERROR: no existe ExportDir: $ExportDir" -ForegroundColor Red; exit 1 }

# Mapa sufijo-de-frame -> ruta destino dentro del PackDir
$map = [ordered]@{
    '01_Overlay_Principal' = '01_Overlay\01_Overlay_Principal.png'
    '02_Panel_Discord'     = '02_Paneles\02_Panel_Discord.png'
    '03_Panel_Instagram'   = '02_Paneles\03_Panel_Instagram.png'
    '04_Panel_Siguiente'   = '02_Paneles\04_Panel_Siguiente.png'
    '05_Starting_Soon'     = '03_Pantallas\05_Starting_Soon.png'
    '06_Be_Right_Back'     = '03_Pantallas\06_Be_Right_Back.png'
    '07_Offline'           = '03_Pantallas\07_Offline.png'
}

foreach ($sub in '01_Overlay','02_Paneles','03_Pantallas','04_Iconos') {
    New-Item -ItemType Directory -Force -Path (Join-Path $PackDir $sub) | Out-Null
}

$faltan = 0
foreach ($key in $map.Keys) {
    $src = Get-ChildItem $ExportDir -Filter "*$key.png" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($src) {
        Copy-Item $src.FullName (Join-Path $PackDir $map[$key]) -Force
        Write-Host "  ok  $key  <- $($src.Name)"
    } else {
        Write-Host "  FALTA  *$key.png en $ExportDir" -ForegroundColor Yellow
        $faltan++
    }
}
if ($faltan -gt 0) { Write-Host "Aviso: faltaron $faltan piezas. Reviso el export." -ForegroundColor Yellow }

# Iconos (opcional): copia los PNG de iconos al pack
if ($IconsDir -and (Test-Path $IconsDir)) {
    $ic = Get-ChildItem $IconsDir -Filter '*.png' -ErrorAction SilentlyContinue
    if ($ic) { $ic | Copy-Item -Destination (Join-Path $PackDir '04_Iconos') -Force; Write-Host "  ok  $($ic.Count) iconos PNG copiados" }
}

# Generar mockups con el script generalizado (mismo directorio)
$builder = Join-Path $PSScriptRoot 'build_pack_mockups.ps1'
$outDir  = Join-Path $PackDir 'Mockups'
Write-Host "== Generando mockups en $outDir =="
& $builder -PackDir $PackDir -OutDir $outDir -Brand $Brand -Subtitle $Subtitle -Accent $Accent
