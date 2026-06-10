# ============================================================================
#  build_all.ps1  —  Corre TODA la pipeline de assets en orden (UN comando)
# ----------------------------------------------------------------------------
#  Genera, de punta a punta, para uno o varios packs (rock/gym/moto):
#    1. Assets del pack  (overlay + paneles + pantallas + iconos)   [por pack]
#    2. Mockups de Etsy del pack                                    [por pack]
#    3. ZIP final del pack (para subir como descarga)               [por pack]
#    4. Pines de Pinterest (~18, verticales 1000x1500)              [una vez]
#    5. Branding de tienda (banner 1200x300 + icono 500x500)        [una vez]
#    6. Mockup del bundle (3 portadas + tabla de ahorro)            [una vez]
#
#  Gym y Moto se generan 100% por codigo igual que Rock: build_pack_assets.ps1
#  ya esta parametrizado por -Pack, asi que NO se necesita Figma.
#
#  USO (desde una terminal PowerShell normal, donde ImageMagick funciona):
#       cd D:\workspace\nicho\Mockups_Etsy
#       .\build_all.ps1                          # solo Rock (compat hacia atras)
#       .\build_all.ps1 -Packs rock,gym,moto     # los tres packs
#       .\build_all.ps1 -Packs gym -Steps 1,2,3  # solo assets+mockups+ZIP de Gym
#
#  Audio (opcional): pasa la carpeta de MP3 por pack para meterlos en el ZIP:
#       .\build_all.ps1 -RockAudioDir "D:\workspace\nicho\audios"
#       .\build_all.ps1 -Packs gym -AudioDirs @{ gym = 'D:\...\_audio_gym' }
#
#  Requisito: ImageMagick instalado (imagemagick.org). Cada sub-script
#  autodetecta magick.exe.
# ============================================================================

param(
    [ValidateSet('rock','gym','moto')][string[]]$Packs = @('rock'),
    [string]$RockAudioDir = '',
    [hashtable]$AudioDirs = @{},
    [int[]]$Steps = @(1,2,3,4,5,6)   # ej: -Steps 1,2,3 para solo assets+mockups+ZIP
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $here

# --- Config por pack (rutas relativas al repo) ------------------------------
$PACK_CFG = @{
    rock = @{ Dir = 'packs\Pack1_Rock\RiffStream_Rock';  Svg = 'packs\Pack1_Rock\svg\icons';
              Subtitle = 'PACK PARA STREAMERS DE ROCK'; Accent = '#E63946' }
    gym  = @{ Dir = 'packs\Pack2_Gym\RiffStream_Iron';   Svg = 'packs\Pack2_Gym\svg\icons';
              Subtitle = 'PACK PARA STREAMERS DE GYM';  Accent = '#F4A259' }
    moto = @{ Dir = 'packs\Pack3_Moto\RiffStream_Ruta';  Svg = 'packs\Pack3_Moto\svg\icons';
              Subtitle = 'PACK PARA STREAMERS DE MOTO'; Accent = '#F4A259' }
}

# -RockAudioDir es un alias comodo para -AudioDirs @{ rock = ... }
if ($RockAudioDir) { $AudioDirs = @{} + $AudioDirs; $AudioDirs['rock'] = $RockAudioDir }

function Step($n, $msg) { Write-Host ""; Write-Host "######## [$n] $msg" -ForegroundColor Cyan }

function Assert-File($path, $what) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Write-Host "ERROR: no se genero $what." -ForegroundColor Red
        Write-Host "       esperado: $path" -ForegroundColor Red
        Write-Host "       (ImageMagick pudo fallar en silencio. Revisa el paso anterior.)" -ForegroundColor Red
        exit 1
    }
}

function Assert-AnyPng($dir, $what) {
    $n = @(Get-ChildItem -LiteralPath $dir -Filter '*.png' -ErrorAction SilentlyContinue).Count
    if ($n -lt 1) {
        Write-Host "ERROR: no se generaron $what (0 PNG en $dir)." -ForegroundColor Red
        exit 1
    }
}

# =================== Pasos POR PACK (1,2,3) =================================
foreach ($pack in $Packs) {
    $cfg     = $PACK_CFG[$pack]
    $packDir = Join-Path $repoRoot $cfg.Dir
    $packSvg = Join-Path $repoRoot $cfg.Svg
    $zipPath = Join-Path (Split-Path $packDir -Parent) ((Split-Path $packDir -Leaf) + '.zip')

    if (1 -in $Steps) {
        Step "1/$pack" "Assets del Pack $pack (ImageMagick, sin Figma)"
        & (Join-Path $here 'build_pack_assets.ps1') -Pack $pack -PackDir $packDir -IconsSvgDir $packSvg
        Assert-File (Join-Path $packDir '01_Overlay\01_Overlay_Principal.png') "el overlay del Pack $pack"
    }

    if (2 -in $Steps) {
        Step "2/$pack" "Mockups de Etsy del Pack $pack"
        $mockOut = Join-Path $packDir 'Mockups'
        & (Join-Path $here 'build_pack_mockups.ps1') `
            -PackDir  $packDir `
            -OutDir   $mockOut `
            -Brand    'RIFFSTREAM' `
            -Subtitle $cfg.Subtitle `
            -Accent   $cfg.Accent
        Assert-AnyPng $mockOut "los mockups del Pack $pack"
    }

    if (3 -in $Steps) {
        Step "3/$pack" "ZIP final del Pack $pack"
        $audioDir = if ($AudioDirs.ContainsKey($pack)) { $AudioDirs[$pack] } else { '' }
        if ($audioDir) {
            $mp3 = @(Get-ChildItem $audioDir -Include '*.mp3','*.wav' -Recurse -ErrorAction SilentlyContinue)
            if ($mp3.Count -lt 1) {
                Write-Host "  AVISO: -AudioDirs[$pack] = '$audioDir' no tiene MP3/WAV. El ZIP saldra con placeholder." -ForegroundColor Yellow
            }
        }
        $zipArgs = @{ PackDir = $packDir; IconsSvgDir = $packSvg }
        if ($audioDir) { $zipArgs.AudioDir = $audioDir }
        & (Join-Path $here 'build_pack_zip.ps1') @zipArgs
        Assert-File $zipPath "el ZIP del Pack $pack"
    }
}

# =================== Pasos GLOBALES (4,5,6) ================================
if (4 -in $Steps) {
    Step 4 'Pines de Pinterest'
    & (Join-Path $here 'build_pinterest_pins.ps1')
}

if (5 -in $Steps) {
    Step 5 'Branding de tienda (banner + icono)'
    & (Join-Path $here 'build_branding.ps1')
}

if (6 -in $Steps) {
    Step 6 'Mockup del bundle'
    & (Join-Path $here 'build_bundle_mockup.ps1')
}

# =================== Resumen ===============================================
Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " TODO LISTO. Packs generados: $($Packs -join ', ')" -ForegroundColor Green
foreach ($pack in $Packs) {
    $packDir = Join-Path $repoRoot $PACK_CFG[$pack].Dir
    $zipPath = Join-Path (Split-Path $packDir -Parent) ((Split-Path $packDir -Leaf) + '.zip')
    Write-Host "  - $pack : $packDir"
    Write-Host "          mockups -> $(Join-Path $packDir 'Mockups')"
    Write-Host "          zip     -> $zipPath"
}
Write-Host "  - Pines     : $(Join-Path $repoRoot 'marketing\pins')"
Write-Host "  - Branding  : $(Join-Path $repoRoot 'branding')"
Write-Host "  - Bundle    : $(Join-Path $repoRoot 'marketing\Bundle_Mockup.png')"
Write-Host "==================================================" -ForegroundColor Green
