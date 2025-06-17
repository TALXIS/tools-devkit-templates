$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot\AppModuleSiteMaps\appexamplename\AppModuleSiteMap.xml').Path
$subareaPath = (Resolve-Path '.template.temp/subarea.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw
[xml]$subareaXml = Get-Content -Path $subareaPath -Raw

$groupNode = $entityXml.SelectSingleNode("//SiteMap/Area[@ResourceId='SitemapDesigner.areatitleexample']/Group[@ResourceId='SitemapDesigner.grouptitleexample']")

if (-not $groupNode) {
    exit 1
}

$importedSubarea = $entityXml.ImportNode($subareaXml.DocumentElement, $true)
$groupNode.AppendChild($importedSubarea) | Out-Null

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()