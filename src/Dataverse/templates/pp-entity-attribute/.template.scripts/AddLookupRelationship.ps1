. "$PSScriptRoot/Save-TxcXml.ps1"

$ErrorActionPreference = 'Stop'

# File Paths
$referencedEntityRelationshipFilePathRaw = '__solution-root-path__/Other/Relationships/__referenced-entity-name__.xml'
$relationshipsFilePathRaw = '__solution-root-path__/Other/Relationships.xml'
$relationshipTemplateFilePathRaw = '.template.temp/lookup-relationship.xml'

# Ensure directories exist
foreach ($path in @($referencedEntityRelationshipFilePathRaw, $relationshipsFilePathRaw)) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

# empty relationship file content
$emptyXmlContent = '<?xml version="1.0" encoding="utf-8"?><EntityRelationships xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></EntityRelationships>'

# Create XML files if they don't exist
foreach ($xmlFile in @($referencedEntityRelationshipFilePathRaw, $relationshipsFilePathRaw)) {
    if (-not (Test-Path $xmlFile)) {
        [xml]$xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.LoadXml($emptyXmlContent)
        Save-TxcXml -Document $xmlDoc -Path ([System.IO.Path]::GetFullPath($xmlFile))
    }
}

# Resolve absolute paths
$relationshipsFilePath = Resolve-Path $relationshipsFilePathRaw
$relationshipTemplateFilePath = Resolve-Path $relationshipTemplateFilePathRaw
$referencedEntityRelationshipFilePath = Resolve-Path $referencedEntityRelationshipFilePathRaw

# Load XML files
[xml]$relationshipsFile = Get-Content $relationshipsFilePath -Raw
[xml]$relationshipTemplateFile = Get-Content $relationshipTemplateFilePath -Raw
[xml]$referencedEntityRelationshipFile = Get-Content $referencedEntityRelationshipFilePath -Raw


# add relationship to referenced entity relationship file (skip if already exists)
$relationshipName = '__lookup-relationship-name__'
$existingInRef = $false
foreach ($node in $referencedEntityRelationshipFile.GetElementsByTagName('EntityRelationship')) {
    if ($node.GetAttribute('Name') -eq $relationshipName) { $existingInRef = $true; break }
}
if ($existingInRef) {
    Write-Host "Relationship '$relationshipName' already exists in $referencedEntityRelationshipFilePathRaw – skipping."
} else {
    $importedNode = $referencedEntityRelationshipFile.ImportNode($relationshipTemplateFile.EntityRelationship, $true)
    $referencedEntityRelationshipFile.EntityRelationships.AppendChild($importedNode) | Out-Null
}

# add relationship element to relationships file (skip if already exists)
$existingInRels = $false
foreach ($node in $relationshipsFile.GetElementsByTagName('EntityRelationship')) {
    if ($node.GetAttribute('Name') -eq $relationshipName) { $existingInRels = $true; break }
}
if ($existingInRels) {
    Write-Host "Relationship '$relationshipName' already exists in $relationshipsFilePathRaw – skipping."
} else {
    $relationshipElement = $relationshipsFile.CreateElement('EntityRelationship')
    $relationshipElement.SetAttribute('Name', $relationshipName)
    $relationshipsFile.EntityRelationships.AppendChild($relationshipElement) | Out-Null
}


Save-TxcXml -Document $relationshipsFile -Path $relationshipsFilePath
Save-TxcXml -Document $referencedEntityRelationshipFile -Path $referencedEntityRelationshipFilePath
