$entityXmlPath = ./.template.scripts/LocateForm

$tabPath = (Resolve-Path './.template.temp/tab.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$tabsNode = $entityXml.SelectSingleNode('//tabs')
if (-not $tabsNode) {
    exit 1
}

$tabRaw = Get-Content -Path $tabPath -Raw
$wrapped = "<tabs>$tabRaw</tabs>"
[xml]$newtabsXml = $wrapped

foreach ($tab in $newtabsXml.tabs.ChildNodes) {
    $imported = $entityXml.ImportNode($tab, $true)
    $tabsNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()