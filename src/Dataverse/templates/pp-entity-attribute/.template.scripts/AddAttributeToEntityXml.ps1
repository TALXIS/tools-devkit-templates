. "$PSScriptRoot/Save-TxcXml.ps1"

$ErrorActionPreference = 'Stop'

# Resolve the relative path to an absolute path (to support other OSes)
$entityXmlPath = (Resolve-Path '__solution-root-path__/Entities/__entity-schema-name__/Entity.xml').Path
$attributeXmlPath = (Resolve-Path '.template.temp/attribute.xml').Path

[XML]$entityXmlFile = Get-Content -Path $entityXmlPath -Raw
[XML]$attributeXmlFile = Get-Content -Path $attributeXmlPath -Raw

$attributeLogicalName = $attributeXmlFile.attribute.LogicalName
$attributesContainer = $entityXmlFile.SelectSingleNode('/Entity/EntityInfo/entity/attributes')

foreach ($attribute in $attributesContainer.attribute) {
    if ($attribute.LogicalName -eq $attributeLogicalName) {
        Write-Warning "Attribute '$attributeLogicalName' already exists in '$entityXmlPath'. Skipping attribute append; existing metadata was not overwritten."
        exit 0
    }
}

# Add attribute to entity
$importedNode = $entityXmlFile.ImportNode($attributeXmlFile.attribute, $true)
$attributesContainer.AppendChild($importedNode) | Out-Null

Save-TxcXml -Document $entityXmlFile -Path $entityXmlPath -ExpandEmptyElements @(
    'AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor',
    'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask',
    'ExternalTypeName'
)
