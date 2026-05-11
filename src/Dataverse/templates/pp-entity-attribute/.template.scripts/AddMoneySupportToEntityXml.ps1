$ErrorActionPreference = 'Stop'

# Resolve the relative path to an absolute path (to support other OSes)
$entityXmlPath = (Resolve-Path '__solution-root-path__/Entities/__entity-schema-name__/Entity.xml').Path

[XML]$entityXmlFile = Get-Content -Path $entityXmlPath -Raw
$attributesContainer = $entityXmlFile.SelectSingleNode('/Entity/EntityInfo/entity/attributes')

function Test-AttributeExists {
    param([string]$LogicalName)

    foreach ($attribute in $attributesContainer.attribute) {
        if ($attribute.LogicalName -eq $LogicalName) {
            return $true
        }
    }

    return $false
}

function Add-AttributeFromTemplate {
    param([string]$TemplatePath)

    [XML]$attributeXmlFile = Get-Content -Path (Resolve-Path $TemplatePath).Path -Raw
    $logicalName = $attributeXmlFile.attribute.LogicalName

    if (-not (Test-AttributeExists -LogicalName $logicalName)) {
        $importedNode = $entityXmlFile.ImportNode($attributeXmlFile.attribute, $true)
        $attributesContainer.AppendChild($importedNode) | Out-Null
    }
}

$hasFullEntityMetadata = $entityXmlFile.SelectSingleNode('/Entity/EntityInfo/entity/LocalizedNames') -ne $null

if ($hasFullEntityMetadata) {
    Add-AttributeFromTemplate '.template.temp/transactioncurrency-attribute.xml'
    Add-AttributeFromTemplate '.template.temp/exchangerate-attribute.xml'
}

Add-AttributeFromTemplate '.template.temp/money-base-attribute.xml'

# Configure XmlWriter settings to avoid unwanted whitespace
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

# Save
$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXmlFile.Save($writer)

$writer.Close()
