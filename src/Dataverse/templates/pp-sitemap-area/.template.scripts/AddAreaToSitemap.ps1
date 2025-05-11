$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot\AppModuleSiteMaps\userprefixexample_appexemplename\AppModuleSiteMap.xml').Path
$areasPath = (Resolve-Path '.template.scripts/area.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$roleareasNode = $entityXml.SelectSingleNode('//SiteMap')
if (-not $roleareasNode) {
    exit 1
}

$roleareasNode.RemoveAll()

$areasRaw = Get-Content -Path $areasPath -Raw
$wrapped = "<Area>$areasRaw</Area>"
[xml]$newareasXml = $wrapped

foreach ($area in $newareasXml.SiteMap.ChildNodes) {
    $imported = $entityXml.ImportNode($area, $true)
    $roleareasNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()

