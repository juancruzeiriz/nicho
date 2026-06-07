# Render del mockup 06_Paneles sin ImageMagick (GDI+ nativo)
# Replica build_pack_mockups.ps1 (seccion MOCKUP 6) usando los PNG de paneles ya generados.
param(
    [string]$PackDir = "D:\workspace\nicho\packs\Pack1_Rock\RiffStream_Rock",
    [string]$Out     = "D:\workspace\nicho\packs\Pack1_Rock\RiffStream_Rock\Mockups\06_Paneles_TEST.png"
)
Add-Type -AssemblyName System.Drawing

$W = 2000; $H = 2000
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Paleta
$bgTop   = [System.Drawing.Color]::FromArgb(255, 38, 38, 43)    # #26262B
$bgBot   = [System.Drawing.Color]::FromArgb(255, 15, 15, 18)    # #0F0F12
$rojo    = [System.Drawing.Color]::FromArgb(255, 230, 57, 70)   # #E63946
$white   = [System.Drawing.Color]::FromArgb(255, 241, 250, 238) # #F1FAEE
$wmark   = [System.Drawing.Color]::FromArgb(102, 241, 250, 238) # blanco 0x66

# Fondo degradado vertical
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $bgTop, $bgBot, 90)
$g.FillRectangle($grad, $rect)

# Barra inferior roja
$brRojo = New-Object System.Drawing.SolidBrush($rojo)
$g.FillRectangle($brRojo, 0, 1990, $W, 10)

# Fuentes
$fTitle = New-Object System.Drawing.Font("Bahnschrift", 150, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fSub   = New-Object System.Drawing.Font("Bahnschrift", 48,  [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fWmark = New-Object System.Drawing.Font("Bahnschrift", 28,  [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$brWhite = New-Object System.Drawing.SolidBrush($white)
$brWmark = New-Object System.Drawing.SolidBrush($wmark)

# Titulo + subtitulo centrados
$fmtC = New-Object System.Drawing.StringFormat
$fmtC.Alignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("PANELES PARA TU PERFIL", $fTitle, $brWhite, (New-Object System.Drawing.PointF(1000, 150)), $fmtC)
$dot = [char]0x00B7
$g.DrawString("3 PANELES LISTOS   $dot   DISCORD   $dot   INSTAGRAM   $dot   SIGUIENTE STREAM", $fSub, $brRojo, (New-Object System.Drawing.PointF(1000, 360)), $fmtC)

# Watermark abajo-derecha
$fmtR = New-Object System.Drawing.StringFormat
$fmtR.Alignment = [System.Drawing.StringAlignment]::Far
$g.DrawString("RIFFSTREAM", $fWmark, $brWmark, (New-Object System.Drawing.PointF(1950, 1935)), $fmtR)

# Paneles (escalados 300x160 -> 1200x640, mismas posiciones que el script magick)
function Draw-Panel($g, $path, $cx, $cy) {
    if (-not (Test-Path $path)) { Write-Host "FALTA: $path"; return }
    $img = [System.Drawing.Image]::FromFile($path)
    $pw = 1200; $ph = 640
    $x = $cx - $pw/2; $y = $cy - $ph/2
    $dest = New-Object System.Drawing.Rectangle([int]$x, [int]$y, $pw, $ph)
    $g.DrawImage($img, $dest)
    $img.Dispose()
}
$pd = Join-Path $PackDir '02_Paneles\02_Panel_Discord.png'
$pi = Join-Path $PackDir '02_Paneles\03_Panel_Instagram.png'
$ps = Join-Path $PackDir '02_Paneles\04_Panel_Siguiente.png'
Draw-Panel $g $pd 1000 690    # +0-310
Draw-Panel $g $pi 1000 1090   # +0+90
Draw-Panel $g $ps 1000 1490   # +0+490

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host ("LISTO -> " + $Out)
