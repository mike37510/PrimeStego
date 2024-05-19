# Définir le dossier contenant les fichiers ZIP et le dossier de sortie
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

# Fonction pour générer un mot aléatoire
function Generate-RandomWord {
    param (
        [int]$length = 5 # Longueur par défaut du mot
    )

    $random = New-Object System.Random
    $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    $word = ""
    1..$length | ForEach-Object {
        $randomIndex = $random.Next(0, $characters.Length)
        $word += $characters[$randomIndex]
    }

    return $word
}

# Fonction pour générer une image avec des formes et des couleurs aléatoires
function Generate-RandomImage {
    param (
        [string]$outputFilePath,
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
        $shapeType = $random.Next(0, 3) # 0: rectangle, 1: cercle, 2: texte
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
            2 { # Texte
                $word = Generate-RandomWord
                $font = [System.Drawing.Font]::new("Arial", 24)
                $x = $random.Next(0, $width - 200)
                $y = $random.Next(0, $height - 200)
                $graphics.DrawString($word, $font, $brushes[$colorIndex], $x, $y)
            }
        }
    }

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
    Generate-RandomImage -outputFilePath $imageFilePath

# Créer le chemin de sortie pour l'image stéganographique avec le nom du fichier ZIP
    $outputFilePath = Join-Path -Path $outputFolder -ChildPath $imageFileName

    # Cacher le fichier ZIP dans l'image
    Hide-ZipInImage -zipFilePath $zipFile.FullName -imageFilePath $imageFilePath -outputFilePath $outputFilePath
}

