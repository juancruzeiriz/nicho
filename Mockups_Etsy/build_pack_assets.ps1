# ============================================================================
#  build_pack_assets.ps1  —  Genera los ASSETS del pack con ImageMagick
# ----------------------------------------------------------------------------
#  Reemplaza la dependencia de Figma: arma overlay + 3 paneles + 3 pantallas
#  + rasteriza los 8 iconos SVG a PNG, replicando el "overlay enriquecido"
#  del plugin (riffstream-plugin-packs/code.js): esquinas decorativas, pill
#  EN VIVO, redes arriba a la derecha y barra inferior de info.
#
#  Pensado para el Pack 1 (Rock), pero parametrizado por -Pack (rock/gym/moto).
#
#  Uso tipico (Rock):
#    .\build_pack_assets.ps1 -Pack rock `
#        -PackDir   "..\packs\Pack1_Rock\RiffStream_Rock" `
#        -IconsSvgDir "..\packs\Pack1_Rock\svg\icons"
#
#  Despues corres build_pack_mockups.ps1 sobre ese PackDir para los mockups.
#  Requisito: ImageMagick (imagemagick.org).
# ============================================================================

param(
    [ValidateSet('rock','gym','moto')][string]$Pack = 'rock',
    [string]$PackDir,
    [string]$IconsSvgDir = '',
    [string]$Magick = ''
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir

# --- Auto-detectar magick.exe (igual que build_pack_mockups.ps1) ------------
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
    Write-Host 'Instalalo desde https://imagemagick.org o pasa -Magick "C:\ruta\magick.exe".'
    exit 1
}

# --- Paleta base (hex) ------------------------------------------------------
$CARBON  = '#1A1A1D'
$GRAFITO = '#26262B'
$ROJO    = '#E63946'
$COBRE   = '#F4A259'
$ACERO   = '#8D99AE'
$WHITE   = '#F1FAEE'

# rgba helpers (para opacidades del plugin)
$GRAFITO22 = 'rgba(38,38,43,0.22)'
$GRAFITO88 = 'rgba(38,38,43,0.88)'
$WHITE92   = 'rgba(241,250,238,0.92)'
$WHITE85   = 'rgba(241,250,238,0.85)'
$WHITE70   = 'rgba(241,250,238,0.70)'

$FONT_TITLE = 'Bahnschrift'   # sustituto de Bebas Neue
$FONT_BODY  = 'Arial'         # sustituto de Inter

# --- Definicion por pack (espeja PACKS de riffstream-plugin-packs) ----------
$PACKS = @{
    rock = @{
        accent = $ROJO; accent2 = $COBRE
        infoBar = 'AHORA SUENA'; infoTxt = 'Nombre del tema  -  Artista'
        panels = @(
            @('DISCORD',        'discord.gg/riffstream', 'A'),
            @('INSTAGRAM',      '@riffstream',           'B'),
            @('PROXIMO STREAM', 'Vie 21 00',             'A')
        )
        screens = @(
            @('RIFFSTREAM', 'EMPEZAMOS PRONTO', 'A'),
            @('YA VUELVO',  'BE RIGHT BACK',    'B'),
            @('OFFLINE',    'EL STREAM TERMINO','W')
        )
    }
    gym = @{
        accent = $COBRE; accent2 = $ROJO
        infoBar = 'RUTINA DE HOY'; infoTxt = 'Pierna  -  5 series'
        panels = @(
            @('DISCORD',        'discord.gg/riffstream', 'A'),
            @('INSTAGRAM',      '@riffstream',           'B'),
            @('PROXIMO STREAM', 'Lun 20 00',             'A')
        )
        screens = @(
            @('RIFFSTREAM', 'EMPEZAMOS PRONTO',        'A'),
            @('YA VUELVO',  'PAUSA ENTRE SERIES',      'B'),
            @('OFFLINE',    'NOS VEMOS EN LA PROXIMA', 'W')
        )
    }
    moto = @{
        accent = $COBRE; accent2 = $ACERO
        infoBar = 'EN RUTA'; infoTxt = 'Proximo destino  -  120 km'
        panels = @(
            @('DISCORD',        'discord.gg/riffstream', 'A'),
            @('INSTAGRAM',      '@riffstream',           'B'),
            @('PROXIMO STREAM', 'Sab 15 00',             'A')
        )
        screens = @(
            @('RIFFSTREAM', 'ARRANCAMOS PRONTO', 'A'),
            @('YA VUELVO',  'PARADA TECNICA',    'B'),
            @('OFFLINE',    'BUENOS KILOMETROS', 'W')
        )
    }
}

$cfg = $PACKS[$Pack]
$accent  = $cfg.accent
$accent2 = $cfg.accent2
# color2 -> resolver letra a hex (A=accent, B=accent2, W=blanco)
function Resolve-Color($code) {
    switch ($code) { 'A' { $accent } 'B' { $accent2 } 'W' { $WHITE } default { $accent } }
}

# rgba del accent2 al 8% para las lineas tenues de pantalla
function To-Rgba08($hex) {
    $h = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($h.Substring(0,2),16)
    $g = [Convert]::ToInt32($h.Substring(2,2),16)
    $b = [Convert]::ToInt32($h.Substring(4,2),16)
    "rgba($r,$g,$b,0.08)"
}
$accent2_08 = To-Rgba08 $accent2

if (-not $PackDir) { $PackDir = Join-Path $repoRoot ("packs\Pack1_Rock\RiffStream_Rock") }
if (-not $IconsSvgDir) { $IconsSvgDir = Join-Path $repoRoot ("packs\Pack1_Rock\svg\icons") }

Write-Host "magick : $magick"
Write-Host "pack   : $Pack"
Write-Host "out    : $PackDir"
Write-Host "accent : $accent  accent2: $accent2"

foreach ($sub in '01_Overlay','02_Paneles','03_Pantallas','04_Iconos') {
    New-Item -ItemType Directory -Force -Path (Join-Path $PackDir $sub) | Out-Null
}

# =============================== OVERLAY =====================================
Write-Host '== Overlay principal =='
$overlayOut = Join-Path $PackDir '01_Overlay\01_Overlay_Principal.png'
$ov = @(
    '-size','1920x1080','xc:none',
    # esquinas (brackets)
    '-fill',$accent2,'-draw','rectangle 40,40 84,46',
    '-fill',$accent2,'-draw','rectangle 40,40 46,84',
    '-fill',$accent,'-draw','rectangle 1836,40 1880,46',
    '-fill',$accent,'-draw','rectangle 1874,40 1880,84',
    '-fill',$accent,'-draw','rectangle 1836,952 1880,958',
    '-fill',$accent,'-draw','rectangle 1874,914 1880,958',
    # linea superior de la camara (accent2)
    '-fill',$accent2,'-draw','rectangle 40,696 460,700',
    # caja de camara: relleno translucido + borde de acento
    '-fill',$GRAFITO22,'-stroke',$accent,'-strokewidth','4','-draw','roundrectangle 40,700 460,1020 10,10','-stroke','none',
    # pill EN VIVO
    '-fill',$accent,'-draw','roundrectangle 56,716 188,756 20,20',
    # barra inferior translucida + tick de acento
    '-fill',$GRAFITO88,'-draw','rectangle 0,1020 1920,1080',
    '-fill',$accent,'-draw','roundrectangle 40,1036 48,1064 2,2',
    # textos
    '-font',$FONT_BODY,'-pointsize','22','-fill',$WHITE,'-gravity','NorthWest','-annotate','+86+723','EN VIVO',
    '-font',$FONT_BODY,'-pointsize','24','-fill',$WHITE92,'-gravity','NorthEast','-annotate','+100+50','discord.gg/riffstream',
    '-font',$FONT_BODY,'-pointsize','20','-fill',$WHITE70,'-gravity','NorthEast','-annotate','+100+84','@riffstream',
    '-font',$FONT_TITLE,'-pointsize','26','-fill',$accent,'-gravity','NorthWest','-annotate','+64+1032',$cfg.infoBar,
    '-font',$FONT_BODY,'-pointsize','20','-fill',$WHITE85,'-gravity','NorthWest','-annotate','+270+1037',$cfg.infoTxt,
    $overlayOut
)
& $magick @ov
Write-Host "   $overlayOut OK"

# =============================== PANELES =====================================
function Build-Panel($out, $titulo, $sub, $acentoCode) {
    $ac = Resolve-Color $acentoCode
    $a = @(
        '-size','300x160','xc:none',
        '-fill',$GRAFITO,'-draw','roundrectangle 0,0 299,159 8,8',
        '-fill',$ac,'-draw','rectangle 0,154 300,160',
        '-fill',$ac,'-draw','roundrectangle 20,20 68,68 6,6',
        '-font',$FONT_TITLE,'-pointsize','28','-fill',$WHITE,'-gravity','NorthWest','-annotate','+84+22',$titulo,
        '-font',$FONT_BODY,'-pointsize','16','-fill',$WHITE70,'-gravity','NorthWest','-annotate','+84+64',$sub,
        '-fill',$accent2,'-draw','rectangle 280,138 286,144',
        $out
    )
    & $magick @a
}
Write-Host '== Paneles =='
$pnames = @('02_Panel_Discord','03_Panel_Instagram','04_Panel_Siguiente')
for ($i=0; $i -lt 3; $i++) {
    $p = $cfg.panels[$i]
    $out = Join-Path $PackDir ('02_Paneles\' + $pnames[$i] + '.png')
    Build-Panel $out $p[0] $p[1] $p[2]
    Write-Host "   $($pnames[$i]).png OK"
}

# =============================== PANTALLAS ===================================
function Build-Screen($out, $t1, $t2, $t2code) {
    $t2color = Resolve-Color $t2code
    $a = @('-size','1920x1080',"xc:$CARBON")
    for ($i=1; $i -le 6; $i++) {
        $y = $i * 154
        $a += '-fill'; $a += $accent2_08; $a += '-draw'; $a += "rectangle 0,$y 1920,$($y+2)"
    }
    $a += '-fill'; $a += $GRAFITO; $a += '-draw'; $a += 'rectangle 0,990 1920,1080'
    $a += '-font'; $a += $FONT_TITLE; $a += '-pointsize'; $a += '140'; $a += '-fill'; $a += $WHITE
    $a += '-gravity'; $a += 'North'; $a += '-annotate'; $a += '+0+360'; $a += $t1
    $a += '-font'; $a += $FONT_TITLE; $a += '-pointsize'; $a += '48'; $a += '-fill'; $a += $t2color
    $a += '-gravity'; $a += 'North'; $a += '-annotate'; $a += '+0+560'; $a += $t2
    $a += $out
    & $magick @a
}
Write-Host '== Pantallas =='
$snames = @('05_Starting_Soon','06_Be_Right_Back','07_Offline')
for ($i=0; $i -lt 3; $i++) {
    $s = $cfg.screens[$i]
    $out = Join-Path $PackDir ('03_Pantallas\' + $snames[$i] + '.png')
    Build-Screen $out $s[0] $s[1] $s[2]
    Write-Host "   $($snames[$i]).png OK"
}

# =============================== ICONOS ======================================
Write-Host '== Iconos (SVG -> PNG 256x256) =='
if (Test-Path $IconsSvgDir) {
    $svgs = Get-ChildItem $IconsSvgDir -Filter '*.svg' | Sort-Object Name
    foreach ($svg in $svgs) {
        $out = Join-Path $PackDir ('04_Iconos\' + [IO.Path]::GetFileNameWithoutExtension($svg.Name) + '.png')
        & $magick -background none $svg.FullName -resize 256x256 $out
        Write-Host "   $([IO.Path]::GetFileName($out)) OK"
    }
} else {
    Write-Host "  aviso: no existe IconsSvgDir: $IconsSvgDir" -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Assets generados. Revisa el overlay y las pantallas antes de los mockups.'
Get-ChildItem $PackDir -Recurse -Filter '*.png' | Select-Object FullName, @{N='KB';E={[int]($_.Length/1KB)}} | Format-Table -AutoSize
