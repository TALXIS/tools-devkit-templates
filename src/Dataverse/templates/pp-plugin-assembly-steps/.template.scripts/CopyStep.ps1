$sourcePath = ".\.template.temp\{pluginstepexampleid}.xml"
$targetDir = ".\SolutionDeclarationsRoot\SdkMessageProcessingSteps"

mkdir "SolutionDeclarationsRoot/SdkMessageProcessingSteps"

if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

Copy-Item $sourcePath $targetDir -Force