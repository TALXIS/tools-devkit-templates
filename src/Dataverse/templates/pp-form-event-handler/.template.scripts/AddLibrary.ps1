$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot\Entities\exampleentityname\FormXml\exampleformtype\{formguididexample}.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$formLibrariesNode = $entityXml.SelectSingleNode('//formLibraries')
if (-not $formLibrariesNode) {
	$entityXml.SelectSingleNode('//form').AppendChild($entityXml.CreateElement('formLibraries')) | Out-Null
	$formLibrariesNode = $entityXml.SelectSingleNode('//formLibraries')
}

# If formLibraries already contains the library, skip adding it
$libraryName = 'examplelibraryname.js'
$existingLibrary = $formLibrariesNode.SelectSingleNode("Library[@name='$libraryName']")

if (-not $existingLibrary) {
	$libraryNode = $entityXml.CreateElement('Library')
	$libraryNode.SetAttribute('name', $libraryName)
	$libraryNode.SetAttribute('libraryUniqueId', '{examplelibraryuniqueid}')
	$formLibrariesNode.AppendChild($libraryNode) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()