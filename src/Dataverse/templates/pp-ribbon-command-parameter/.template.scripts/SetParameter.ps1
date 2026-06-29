. "$PSScriptRoot/Save-TxcXml.ps1"

$ErrorActionPreference = 'Stop'

$commandDefinitionId = "__publisher-prefix__.__entity-logical-name__.Command.__button-logical-name__"
$functionName = "__function-name__"
$ribbonXmlPath = (Resolve-Path './__solution-root-path__/Entities/__entity-logical-name__/RibbonDiff.xml').Path
$parameterXmlPath = (Resolve-Path './.template.temp/parameter.xml').Path

[xml]$ribbonXml = Get-Content $ribbonXmlPath -Raw
[xml]$parameterXml = Get-Content $parameterXmlPath -Raw

$commandDefinition = $ribbonXml.SelectSingleNode("//CommandDefinition[@Id='$commandDefinitionId']")

if (-not $commandDefinition) {
    $available = ($ribbonXml.SelectNodes('//CommandDefinition') | ForEach-Object { $_.Id }) -join ', '
    Write-Error "CommandDefinition '$commandDefinitionId' not found in RibbonDiff.xml. Available: $available"
    exit 1
}

$javaScriptFunction = $commandDefinition.SelectSingleNode(".//JavaScriptFunction[@FunctionName='$functionName']")

if (-not $javaScriptFunction) {
    $available = ($commandDefinition.SelectNodes('.//JavaScriptFunction') | ForEach-Object { $_.FunctionName }) -join ', '
    Write-Error "JavaScriptFunction '$functionName' not found in CommandDefinition '$commandDefinitionId'. Available: $available"
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

Save-TxcXml -Document $ribbonXml -Path $ribbonXmlPath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')
Write-Host "Successfully added parameters to '$functionName' in command '$commandDefinitionId'"
