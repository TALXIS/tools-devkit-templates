$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot\AppModuleSiteMaps\userprefixexample_appexamplename\AppModuleSiteMap.xml').Path
$subareaPath = (Resolve-Path '.template.temp/subarea.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw
[xml]$subareaXml = Get-Content -Path $subareaPath -Raw

# Предполагаем, что <Area> и <Group> по одному
$groupNode = $entityXml.SelectSingleNode("//SiteMap/Area/Group")
if (-not $groupNode) {
    Write-Host "Group not found"
    exit 1
}

# Вставка <SubArea> в <Group>
$importedSubarea = $entityXml.ImportNode($subareaXml.DocumentElement, $true)
$groupNode.AppendChild($importedSubarea) | Out-Null

# Сохраняем
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()