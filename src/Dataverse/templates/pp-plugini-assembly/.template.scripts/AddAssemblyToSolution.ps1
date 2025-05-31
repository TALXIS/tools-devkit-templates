$sourceFile = ".template.temp\RootComponent.xml"
$destinationFile = "SolutionDeclarationsRoot\Other\Solution.xml"

[xml]$sourceXml = Get-Content $sourceFile
[xml]$destinationXml = Get-Content $destinationFile

$rootComponent = $sourceXml.DocumentElement

$rootComponentsNode = $destinationXml.SelectSingleNode("//RootComponents")
    
$importNode = $destinationXml.ImportNode($rootComponent, $true)
$rootComponentsNode.AppendChild($importNode)

$destinationXml.Save($destinationFile)