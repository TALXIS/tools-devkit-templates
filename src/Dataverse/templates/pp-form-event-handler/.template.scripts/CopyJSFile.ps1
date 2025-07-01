$pathToFunction = (Resolve-Path 'libraryprojectrootpathexample').Path

$functionName = [System.IO.Path]::GetFileNameWithoutExtension($pathToFunction)

$cleanName = ($functionName -replace '[\p{P}\s]', '')

$logicalName = "examplepublisherprefix_$cleanName"

$webResourcesPath = (Resolve-Path 'SolutionDeclarationsRoot/WebResources').Path
$destinationPath = Join-Path -Path $webResourcesPath -ChildPath "$logicalName"

if (Test-Path $pathToFunction) {
    Copy-Item -Path $pathToFunction -Destination $destinationPath -Force
} else {
    throw "File at $pathToFunction not found."
}

$dataXmlSource = Join-Path -Path $webResourcesPath -ChildPath 'data.xml'
$dataXmlDest = Join-Path -Path $webResourcesPath -ChildPath ("$logicalName.data.xml")

(Get-Content $dataXmlSource -Raw) -replace 'examplelogicalname', $logicalName | Set-Content $dataXmlDest
(Get-Content $dataXmlDest -Raw) -replace 'exampledisplayname', $functionName | Set-Content $dataXmlDest

Remove-Item -Path $dataXmlSource

