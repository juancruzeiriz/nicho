# Render del panel "PROXIMO" sin ImageMagick (GDI+ nativo de Windows)
param(
    [string]$Out = "D:\workspace\nicho\packs\Pack1_Rock\RiffStream_Rock\02_Paneles\TEST_panel_gdi.png",
    [string]$Titulo = "PROXIMO",
    [string]$Sub = "Vie 21 00"
)
Add-Type -AssemblyName System.Drawing

$W = 300; $H = 160
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.Color]::Transparent)

# Colores (rgb del pack)
$grafito = [System.Drawing.Color]::FromArgb(255, 38, 38, 43)    # #26262B
$rojo    = [System.Drawing.Color]::FromArgb(255, 230, 57, 70)   # #E63946
$cobre   = [System.Drawing.Color]::FromArgb(255, 244, 162, 89)  # #F4A259
$white   = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$white70 = [System.Drawing.Color]::FromArgb(180, 241, 250, 238)

function New-RoundPath($x, $y, $w, $h, $r) {
    $d = $r * 2
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

# Fondo grafito redondeado
$bg = New-Object System.Drawing.SolidBrush($grafito)
$pathBg = New-RoundPath 0 0 299 159 8
$g.FillPath($bg, $pathBg)

# Barra inferior roja (acento)
$brRojo = New-Object System.Drawing.SolidBrush($rojo)
$g.FillRectangle($brRojo, 0, 154, 300, 6)

# Cuadrito de icono (rojo, redondeado) 20,20 -> 68,68
$pathIcon = New-RoundPath 20 20 48 48 6
$g.FillPath($brRojo, $pathIcon)

# Cuadradito cobre decorativo (280,138 -> 286,144)
$brCobre = New-Object System.Drawing.SolidBrush($cobre)
$g.FillRectangle($brCobre, 280, 138, 6, 6)

# Textos
$fTitulo = New-Object System.Drawing.Font("Bahnschrift", 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fSub    = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$brWhite   = New-Object System.Drawing.SolidBrush($white)
$brWhite70 = New-Object System.Drawing.SolidBrush($white70)

$fmt = New-Object System.Drawing.StringFormat
$fmt.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap

$g.DrawString($Titulo, $fTitulo, $brWhite,   (New-Object System.Drawing.PointF(84, 24)), $fmt)
$g.DrawString($Sub,    $fSub,    $brWhite70, (New-Object System.Drawing.PointF(85, 64)), $fmt)

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host ("LISTO -> " + $Out)
