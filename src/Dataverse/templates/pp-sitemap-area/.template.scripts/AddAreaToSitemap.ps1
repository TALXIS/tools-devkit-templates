$entityXmlPath = (Resolve-Path 'Declarations\AppModuleSiteMaps\tom_WarehouseApp\AppModuleSiteMap.xml').Path
$areaPath  = (Resolve-Path '.template.temp/area.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw
[xml]$areaXml = Get-Content -Path $areaPath -Raw

$siteMapNode = $entityXml.SelectSingleNode('//SiteMap')
if (-not $siteMapNode) {
    exit 1
}

$imported = $entityXml.ImportNode($areaXml.DocumentElement, $true)
$siteMapNode.AppendChild($imported) | Out-Null

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()