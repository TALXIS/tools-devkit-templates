$TabName = "stageexamplename"

$entityXmlPath=(Resolve-Path './SolutionDeclarationsRoot/Entities/examplebpfname/FormXml/main/{formguididexample}.xml').Path
$rowPath = (Resolve-Path './.template.temp/row.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$targetTab = $entityXml.SelectSingleNode("//tab[labels/label[@description='$TabName']]")
if (-not $targetTab) {
    Write-Error "Tab with description '$TabName' not found in the form XML"
    exit 1
}

$rowsNode = $targetTab.SelectSingleNode('.//rows')
if (-not $rowsNode) {
    Write-Error "Rows element not found in tab '$TabName'"
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