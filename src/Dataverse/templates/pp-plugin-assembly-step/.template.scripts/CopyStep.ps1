$sourcePath = "./.template.temp/__step-id__.xml"
$targetDir = "./__solution-root-path__/SdkMessageProcessingSteps"
$targetFile = Join-Path $targetDir "{__step-id__}.xml"

if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

Copy-Item $sourcePath $targetFile -Force