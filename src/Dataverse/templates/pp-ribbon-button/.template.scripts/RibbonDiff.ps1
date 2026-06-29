. "$PSScriptRoot/Save-TxcXml.ps1"

$ErrorActionPreference = 'Stop'

$ribbonXmlRaw = './__solution-root-path__/Entities/__entity-logical-name__/RibbonDiff.xml'

# Create empty RibbonDiff.xml from template if entity doesn't have one
if (-not (Test-Path $ribbonXmlRaw)) {
    $dir = Split-Path $ribbonXmlRaw
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item './.template.temp/ribbon-diff-empty.xml' $ribbonXmlRaw
    Write-Host "Created missing RibbonDiff.xml at $ribbonXmlRaw"
}

$ribbonXmlPath = (Resolve-Path $ribbonXmlRaw).Path
$commandDefinitionPath = (Resolve-Path './.template.temp/command-definition.xml').Path
$locLabelsPath = (Resolve-Path './.template.temp/loc-labels.xml').Path
$customActionPath = (Resolve-Path './.template.temp/custom-action.xml').Path

[xml]$ribbonXml = Get-Content $ribbonXmlPath -Raw

function Add-XmlContent {
    param (
        [xml]$parentXml,
        [string]$nodeName,
        [string]$contentPath
    )
    if (Test-Path $contentPath) {
        [xml]$contentXml = Get-Content $contentPath -Raw
        foreach ($child in $contentXml.DocumentElement.ChildNodes) {
            $imported = $parentXml.ImportNode($child, $true)
            $targetNode = $parentXml.SelectSingleNode("//*[local-name()='$nodeName']")
            if ($targetNode) {
                $targetNode.AppendChild($imported) | Out-Null
            }
        }
    }
}

Add-XmlContent -parentXml $ribbonXml -nodeName "CommandDefinitions" -contentPath $commandDefinitionPath
Add-XmlContent -parentXml $ribbonXml -nodeName "LocLabels" -contentPath $locLabelsPath
Add-XmlContent -parentXml $ribbonXml -nodeName "CustomActions" -contentPath $customActionPath

Save-TxcXml -Document $ribbonXml -Path $ribbonXmlPath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')
