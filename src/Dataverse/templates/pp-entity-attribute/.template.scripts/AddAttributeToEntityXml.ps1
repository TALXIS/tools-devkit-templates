﻿# Resolve the relative path to an absolute path (to support other OSes)
$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot/Entities/exampleexistingentity/Entity.xml').Path
$attributeXmlPath = (Resolve-Path '.template.temp/attribute.xml').Path

[XML]$entityXmlFile = Get-Content -Path $entityXmlPath -Raw
[XML]$attributeXmlFile = Get-Content -Path $attributeXmlPath -Raw

# Add attribute to entity
$importedNode = $entityXmlFile.ImportNode($attributeXmlFile.attribute, $true)
$entityXmlFile.Entity.EntityInfo.entity.attributes.AppendChild($importedNode) | Out-Null

# Configure XmlWriter settings to avoid unwanted whitespace
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

# Save
$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXmlFile.Save($writer)

$writer.Close()