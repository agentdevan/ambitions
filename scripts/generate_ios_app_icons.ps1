param(
    [string]$OutputDir = "Native/Ambitions/Resources/Assets.xcassets/AppIcon.appiconset"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
$drawing2D = "System.Drawing.Drawing2D"

$specs = @(
    @{ idiom = "iphone"; size = "20x20"; scale = "2x"; pixels = 40; filename = "AppIcon-20@2x.png" },
    @{ idiom = "iphone"; size = "20x20"; scale = "3x"; pixels = 60; filename = "AppIcon-20@3x.png" },
    @{ idiom = "iphone"; size = "29x29"; scale = "2x"; pixels = 58; filename = "AppIcon-29@2x.png" },
    @{ idiom = "iphone"; size = "29x29"; scale = "3x"; pixels = 87; filename = "AppIcon-29@3x.png" },
    @{ idiom = "iphone"; size = "40x40"; scale = "2x"; pixels = 80; filename = "AppIcon-40@2x.png" },
    @{ idiom = "iphone"; size = "40x40"; scale = "3x"; pixels = 120; filename = "AppIcon-40@3x.png" },
    @{ idiom = "iphone"; size = "60x60"; scale = "2x"; pixels = 120; filename = "AppIcon-60@2x.png" },
    @{ idiom = "iphone"; size = "60x60"; scale = "3x"; pixels = 180; filename = "AppIcon-60@3x.png" },
    @{ idiom = "ipad"; size = "20x20"; scale = "1x"; pixels = 20; filename = "AppIcon-20@1x.png" },
    @{ idiom = "ipad"; size = "20x20"; scale = "2x"; pixels = 40; filename = "AppIcon-20~ipad@2x.png" },
    @{ idiom = "ipad"; size = "29x29"; scale = "1x"; pixels = 29; filename = "AppIcon-29@1x.png" },
    @{ idiom = "ipad"; size = "29x29"; scale = "2x"; pixels = 58; filename = "AppIcon-29~ipad@2x.png" },
    @{ idiom = "ipad"; size = "40x40"; scale = "1x"; pixels = 40; filename = "AppIcon-40@1x.png" },
    @{ idiom = "ipad"; size = "40x40"; scale = "2x"; pixels = 80; filename = "AppIcon-40~ipad@2x.png" },
    @{ idiom = "ipad"; size = "76x76"; scale = "1x"; pixels = 76; filename = "AppIcon-76@1x.png" },
    @{ idiom = "ipad"; size = "76x76"; scale = "2x"; pixels = 152; filename = "AppIcon-76@2x.png" },
    @{ idiom = "ipad"; size = "83.5x83.5"; scale = "2x"; pixels = 167; filename = "AppIcon-83.5@2x.png" },
    @{ idiom = "ios-marketing"; size = "1024x1024"; scale = "1x"; pixels = 1024; filename = "AppIcon-1024.png" }
)

function New-RoundedRectPath {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [float]$Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $Radius * 2
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Draw-AppIcon {
    param([int]$Size)

    $bitmap = New-Object System.Drawing.Bitmap $Size, $Size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $backgroundRect = New-Object System.Drawing.RectangleF -ArgumentList @(0, 0, $Size, $Size)
    $backgroundPath = New-RoundedRectPath -X 0 -Y 0 -Width $Size -Height $Size -Radius ($Size * 0.225)
    $gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush -ArgumentList @(
        $backgroundRect,
        [System.Drawing.Color]::FromArgb(255, 13, 43, 64),
        [System.Drawing.Color]::FromArgb(255, 81, 159, 125),
        315.0
    )
    $graphics.FillPath($gradientBrush, $backgroundPath)

    $glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($backgroundPath)
    $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(96, 246, 205, 150)
    $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    $graphics.FillPath($glowBrush, $backgroundPath)

    $ringPenOuter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(86, 255, 255, 255), [float]($Size * 0.05))
    $ringPenInner = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 214, 244, 228), [float]($Size * 0.03))
    $graphics.DrawEllipse($ringPenOuter, $Size * 0.12, $Size * 0.14, $Size * 0.76, $Size * 0.76)
    $graphics.DrawEllipse($ringPenInner, $Size * 0.26, $Size * 0.28, $Size * 0.48, $Size * 0.48)

    $haloBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 244, 251, 247))
    $graphics.FillEllipse($haloBrush, $Size * 0.40, $Size * 0.40, $Size * 0.20, $Size * 0.20)

    $fontSize = [float]($Size * 0.44)
    $fontFamily = New-Object System.Drawing.FontFamily("Segoe UI")
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    $textRect = New-Object System.Drawing.RectangleF -ArgumentList @(($Size * 0.18), ($Size * 0.17), ($Size * 0.64), ($Size * 0.62))
    $letterFont = New-Object System.Drawing.Font -ArgumentList @($fontFamily, $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70, 11, 25, 32))
    $graphics.DrawString(
        "A",
        $letterFont,
        $shadowBrush,
        (New-Object System.Drawing.RectangleF -ArgumentList @($textRect.X, ($textRect.Y + ($Size * 0.018)), $textRect.Width, $textRect.Height)),
        $stringFormat
    )

    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 248, 251, 250))
    $graphics.DrawString(
        "A",
        $letterFont,
        $textBrush,
        $textRect,
        $stringFormat
    )

    $barBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 228, 244, 236))
    $graphics.FillRectangle($barBrush, $Size * 0.33, $Size * 0.64, $Size * 0.34, $Size * 0.05)

    $graphics.Dispose()
    $gradientBrush.Dispose()
    $glowBrush.Dispose()
    $ringPenOuter.Dispose()
    $ringPenInner.Dispose()
    $haloBrush.Dispose()
    $shadowBrush.Dispose()
    $textBrush.Dispose()
    $barBrush.Dispose()
    $backgroundPath.Dispose()
    $fontFamily.Dispose()
    $letterFont.Dispose()
    $stringFormat.Dispose()

    return $bitmap
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

foreach ($spec in $specs) {
    $bitmap = Draw-AppIcon -Size $spec.pixels
    $path = Join-Path $OutputDir $spec.filename
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

$contents = @{
    images = @(
        foreach ($spec in $specs) {
            @{
                size = $spec.size
                idiom = $spec.idiom
                filename = $spec.filename
                scale = $spec.scale
            }
        }
    )
    info = @{
        version = 1
        author = "xcode"
    }
} | ConvertTo-Json -Depth 6

Set-Content -Path (Join-Path $OutputDir "Contents.json") -Value $contents
Write-Host "Generated AppIcon asset set at $OutputDir"
