# File Paths
$referencedEntityRelationshipFilePathRaw = 'SolutionDeclarationsRoot/Other/Relationships/examplereferencedentityname.xml'
$relationshipsFilePathRaw = 'SolutionDeclarationsRoot/Other/Relationships.xml'
$relationshipTemplateFilePathRaw = '.template.temp/LookupRelationship.xml'

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
        $xmlDoc.Save($xmlFile)
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


# add relationship to referenced entity relationship file
$importedNode = $referencedEntityRelationshipFile.ImportNode($relationshipTemplateFile.EntityRelationship, $true)
$referencedEntityRelationshipFile.EntityRelationships.AppendChild($importedNode) | Out-Null

# add relationship element to relationships file as the following element: <EntityRelationship Name="examplelookuprelationshipname" />
$relationshipElement = $relationshipsFile.CreateElement('EntityRelationship')
$relationshipElement.SetAttribute('Name', 'examplelookuprelationshipname')
$relationshipsFile.EntityRelationships.AppendChild($relationshipElement) | Out-Null


# Configure XmlWriter settings to avoid unwanted whitespace
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

# Save relationships file
$writer = [System.Xml.XmlWriter]::Create($relationshipsFilePath, $settings)
$relationshipsFile.Save($writer)
$writer.Close()

# Save referenced entity relationship file
$writer = [System.Xml.XmlWriter]::Create($referencedEntityRelationshipFilePath, $settings)
$referencedEntityRelationshipFile.Save($writer)
$writer.Close()
