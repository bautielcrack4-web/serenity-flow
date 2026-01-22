param (
    [string]$InputPath,
    [string]$OutputPath,
    [int]$Width = 2732,
    [int]$Height = 2048
)

Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($InputPath)

# Create a new bitmap with NO alpha channel (Format24bppRgb)
$bmp = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)

# Fill background with white (just in case there was any transparency in the source)
$g.Clear([System.Drawing.Color]::White)

$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($img, 0, 0, $Width, $Height)

# Save as PNG (Apple accepts PNG, but without alpha)
$bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$img.Dispose()
