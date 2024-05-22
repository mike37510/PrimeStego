# Définir les dossiers
$zipFolder = "C:\MyData\zip"
$outputFolder = "C:\MyData\photos"

# Créer le dossier de sortie s'il n'existe pas
if (-Not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

# Fonction pour obtenir la taille du fichier en Mo
function Get-FileSizeInMB {
    param (
        [string]$filePath
    )
    $fileInfo = Get-Item $filePath
    return [math]::Round($fileInfo.Length / 1MB, 2)
}

# Fonction pour générer une image avec des formes et des couleurs aléatoires
function Generate-RandomImage {
    param (
        [string]$outputFilePath,
        [string]$fileName,
        [int]$width = 3840,
        [int]$height = 2160,
        [int]$maxShapes = 10
    )

    Add-Type -AssemblyName System.Drawing

    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Black)

    $random = New-Object System.Random
    $brushes = [System.Collections.ArrayList]@()

    # Ajouter des couleurs aléatoires aux pinceaux
    1..$maxShapes | ForEach-Object {
        $brushes.Add([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(
            $random.Next(0, 256), # R
            $random.Next(0, 256), # G
            $random.Next(0, 256)  # B
        )))
    }

    # Dessiner des formes aléatoires
    1..$random.Next(1, $maxShapes) | ForEach-Object {
        $shapeType = $random.Next(0, 5) # 0: rectangle, 1: cercle, 2: triangle, 3: trait, 4: pixel
        $colorIndex = $random.Next(0, $brushes.Count)

        switch ($shapeType) {
            0 { # Rectangle
                $x = $random.Next(0, $width - 200)
                $y = $random.Next(0, $height - 200)
                $rectangle = [System.Drawing.Rectangle]::new($x, $y, 200, 200)
                $graphics.FillRectangle($brushes[$colorIndex], $rectangle)
            }
            1 { # Cercle
                $x = $random.Next(0, $width - 200)
                $y = $random.Next(0, $height - 200)
                $rectangle = [System.Drawing.Rectangle]::new($x, $y, 200, 200)
                $graphics.FillEllipse($brushes[$colorIndex], $rectangle)
            }
            2 { # Triangle
                $points = @(
                    [System.Drawing.Point]::new($random.Next(0, $width), $random.Next(0, $height)),
                    [System.Drawing.Point]::new($random.Next(0, $width), $random.Next(0, $height)),
                    [System.Drawing.Point]::new($random.Next(0, $width), $random.Next(0, $height))
                )
                $graphics.FillPolygon($brushes[$colorIndex], $points)
            }
            3 { # Trait
                $x1 = $random.Next(0, $width)
                $y1 = $random.Next(0, $height)
                $x2 = $random.Next(0, $width)
                $y2 = $random.Next(0, $height)
                $graphics.DrawLine([System.Drawing.Pen]::new($brushes[$colorIndex].Color), $x1, $y1, $x2, $y2)
            }
            4 { # Pixel
                $x = $random.Next(0, $width)
                $y = $random.Next(0, $height)
                $graphics.FillRectangle($brushes[$colorIndex], $x, $y, 1, 1)
            }
        }
    }

    # Afficher le nom du fichier sans l'extension .zip à un endroit aléatoire
    $fontSize = $random.Next(24, 60)
    $font = [System.Drawing.Font]::new("Arial", $fontSize)

    # Calculer la taille du texte pour s'assurer qu'il soit entièrement visible
    $textSize = $graphics.MeasureString($fileName, $font)
    $textX = $random.Next(0, [math]::Max(0, $width - $textSize.Width))
    $textY = $random.Next(0, [math]::Max(0, $height - $textSize.Height))

    $graphics.DrawString($fileName, $font, [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White), $textX, $textY)

    $bitmap.Save($outputFilePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bitmap.Dispose()
    $graphics.Dispose()
}

# Fonction pour cacher un fichier ZIP dans une image
function Hide-ZipInImage {
    param (
        [string]$zipFilePath,
        [string]$imageFilePath,
        [string]$outputFilePath
    )

    # Lire le contenu de l'image et du fichier ZIP
    $imageBytes = [System.IO.File]::ReadAllBytes($imageFilePath)
    $zipBytes = [System.IO.File]::ReadAllBytes($zipFilePath)

    # Combiner les octets de l'image et du fichier ZIP
    $combinedBytes = $imageBytes + $zipBytes

    # Écrire les octets combinés dans le fichier de sortie
    [System.IO.File]::WriteAllBytes($outputFilePath, $combinedBytes)
}

# Parcourir les fichiers ZIP dans le dossier
Get-ChildItem -Path $zipFolder -Filter *.zip | ForEach-Object {
    $zipFile = $_

    # Générer une image avec des formes et des couleurs aléatoires
    $imageFileName = "$($zipFile.BaseName).jpg"
    $imageFilePath = Join-Path -Path $outputFolder -ChildPath $imageFileName
    Generate-RandomImage -outputFilePath $imageFilePath -fileName $zipFile.BaseName

    # Créer le chemin de sortie pour l'image stéganographique avec le nom du fichier ZIP
    $outputFilePath = Join-Path -Path $outputFolder -ChildPath $imageFileName

    # Cacher le fichier ZIP dans l'image
    Hide-ZipInImage -zipFilePath $zipFile.FullName -imageFilePath $imageFilePath -outputFilePath $outputFilePath
}
