$ErrorActionPreference = 'Stop'

$commandDefinitionId = "__publisher-prefix__.__entity-logical-name__.Command.__button-logical-name__"
$ribbonXmlPath = (Resolve-Path './__solution-root-path__/Entities/__entity-logical-name__/RibbonDiff.xml').Path
$parameterXmlPath = (Resolve-Path './.template.temp/parameter.xml').Path

[xml]$ribbonXml = Get-Content $ribbonXmlPath -Raw
[xml]$parameterXml = Get-Content $parameterXmlPath -Raw

$commandDefinition = $ribbonXml.SelectSingleNode("//CommandDefinition[@Id='$commandDefinitionId']")

if (-not $commandDefinition) {
    Write-Error "CommandDefinition with ID '$commandDefinitionId' not found in RibbonDiff.xml. Available IDs: $($ribbonXml.SelectNodes('//CommandDefinition') | ForEach-Object { $_.Id })"
    exit 1
}

$javaScriptFunction = $commandDefinition.SelectSingleNode(".//JavaScriptFunction")

if (-not $javaScriptFunction) {
    Write-Error "No JavaScriptFunction found in CommandDefinition '$commandDefinitionId'"
    exit 1
}

$parameters = $parameterXml.SelectNodes("//Parameters/*")

if ($parameters.Count -eq 0) {
    Write-Warning "No parameters found in parameter.xml"
    exit 0
}

foreach ($parameter in $parameters) {
    $clonedParameter = $ribbonXml.ImportNode($parameter, $true)
    $javaScriptFunction.AppendChild($clonedParameter) | Out-Null
    Write-Host "Added parameter: $($parameter.Name)"
}

$ribbonXml.Save($ribbonXmlPath)
Write-Host "Successfully updated RibbonDiff.xml with parameters"
