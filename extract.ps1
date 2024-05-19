# Définir le dossier contenant les images stéganographiques et le dossier de sortie
$inputFolder = "C:\MyData\photos"
$outputFolder = "C:\MyData\zip_extracted"

# Créer le dossier de sortie s'il n'existe pas
if (-Not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

# Fonction pour extraire le fichier ZIP de l'image stéganographique
function Extract-ZipFromImage {
    param (
        [string]$imageFilePath,
        [string]$outputFolderPath
    )

    $imageBytes = [System.IO.File]::ReadAllBytes($imageFilePath)

    # Définition des en-têtes de fichier ZIP
    $zipHeader = [byte[]](0x50, 0x4B, 0x03, 0x04)  # En-tête du fichier ZIP en bytes

    # Recherche de l'index du premier en-tête de fichier ZIP
    $zipIndex = 0
    for ($i = 0; $i -lt ($imageBytes.Length - 3); $i++) {
        $match = $true
        for ($j = 0; $j -lt 4; $j++) {
            if ($imageBytes[$i + $j] -ne $zipHeader[$j]) {
                $match = $false
                break
            }
        }
        if ($match) {
            $zipIndex = $i
            break
        }
    }

    if ($zipIndex -ne 0) {
        # Extraire le contenu du fichier ZIP à partir de l'index trouvé
        $zipContent = $imageBytes[$zipIndex..($imageBytes.Length - 1)]
        $outputFilePath = Join-Path -Path $outputFolderPath -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($imageFilePath) + ".zip")
        [System.IO.File]::WriteAllBytes($outputFilePath, $zipContent)
        Write-Host "Fichier ZIP extrait avec succès : $outputFilePath"
    } else {
        Write-Host "Aucun fichier ZIP trouvé dans l'image : $imageFilePath"
    }
}

# Parcourir les images stéganographiques dans le dossier
Get-ChildItem -Path $inputFolder -Filter *.jpg | ForEach-Object {
    $imageFile = $_
    Extract-ZipFromImage -imageFilePath $imageFile.FullName -outputFolderPath $outputFolder
}
