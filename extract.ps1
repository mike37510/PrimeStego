# D�finir le dossier contenant les images st�ganographiques et le dossier de sortie
$inputFolder = "C:\MyData\photos"
$outputFolder = "C:\MyData\zip_extracted"

# Cr�er le dossier de sortie s'il n'existe pas
if (-Not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

# Fonction pour extraire le fichier ZIP de l'image st�ganographique
function Extract-ZipFromImage {
    param (
        [string]$imageFilePath,
        [string]$outputFolderPath
    )

    $imageBytes = [System.IO.File]::ReadAllBytes($imageFilePath)

    # D�finition des en-t�tes de fichier ZIP
    $zipHeader = [byte[]](0x50, 0x4B, 0x03, 0x04)  # En-t�te du fichier ZIP en bytes

    # Recherche de l'index du premier en-t�te de fichier ZIP
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
        # Extraire le contenu du fichier ZIP � partir de l'index trouv�
        $zipContent = $imageBytes[$zipIndex..($imageBytes.Length - 1)]
        $outputFilePath = Join-Path -Path $outputFolderPath -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($imageFilePath) + ".zip")
        [System.IO.File]::WriteAllBytes($outputFilePath, $zipContent)
        Write-Host "Fichier ZIP extrait avec succ�s : $outputFilePath"
    } else {
        Write-Host "Aucun fichier ZIP trouv� dans l'image : $imageFilePath"
    }
}

# Parcourir les images st�ganographiques dans le dossier
Get-ChildItem -Path $inputFolder -Filter *.jpg | ForEach-Object {
    $imageFile = $_
    Extract-ZipFromImage -imageFilePath $imageFile.FullName -outputFolderPath $outputFolder
}
