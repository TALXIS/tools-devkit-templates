$entityXmlPath = ./.template.scripts/LocateForm.ps1

# Exit early without error if the parent directory is named 'Dialogs'
$parentDir = Split-Path -Parent -Path $entityXmlPath
$parentName = Split-Path -Leaf -Path $parentDir
if ($parentName -eq 'Dialogs') { exit 0 }

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