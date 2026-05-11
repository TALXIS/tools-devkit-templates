$targetXmlPath = (Resolve-Path '__solution-root-path__/Entities\examplebpfname\FormXml\main\{mainFormIdexample}.xml').Path
$stageFormPath = (Resolve-Path '.template.temp\stageForm.xml').Path

[xml]$targetXml = Get-Content -Path $targetXmlPath -Raw
[xml]$stageFormXml = Get-Content -Path $stageFormPath -Raw

$tabsNode = $targetXml.SelectSingleNode('//tabs')

if (-not $tabsNode) {
    Write-Error "Could not find tabs node in the target form XML."
    exit 1
}

foreach ($child in $stageFormXml.DocumentElement.ChildNodes) {
    $imported = $targetXml.ImportNode($child, $true)
    $tabsNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($targetXmlPath, $settings)
$targetXml.Save($writer)
$writer.Close()