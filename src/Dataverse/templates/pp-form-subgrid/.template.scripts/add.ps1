$entityXmlPath = (Resolve-Path './__solution-declarations-root__/Entities/__entity-logical-name__/FormXml/__form-type__/{__form-id__}.xml').Path
$rowPath = (Resolve-Path './.template.temp/subgrid.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$rowsNode = $entityXml.SelectSingleNode('//rows')
if (-not $rowsNode) {
    Write-Error "Could not find rows node in the XML file."
    exit 1
}

$rowRaw = Get-Content -Path $rowPath -Raw
$wrapped = "<rows>$rowRaw</rows>"
[xml]$newRowsXml = $wrapped

foreach ($row in $newRowsXml.rows.ChildNodes) {
    $imported = $entityXml.ImportNode($row, $true)
    $rowsNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()