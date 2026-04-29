$sourceFile = ".template.temp/RootComponent.xml"
$destinationFile = "SolutionDeclarationsRoot/Other/Solution.xml"

if (-not (Test-Path $sourceFile)) {
    Write-Error "RootComponent.xml not found at '$sourceFile'. GenerateAssembly.csx likely failed. Ensure the plugin project is built (dotnet publish) and signed."
    exit 1
}

[xml]$sourceXml = Get-Content $sourceFile
[xml]$destinationXml = Get-Content $destinationFile

$rootComponent = $sourceXml.DocumentElement

$rootComponentsNode = $destinationXml.SelectSingleNode("//RootComponents")
    
$importNode = $destinationXml.ImportNode($rootComponent, $true)
$rootComponentsNode.AppendChild($importNode)

$destinationXml.Save($destinationFile)