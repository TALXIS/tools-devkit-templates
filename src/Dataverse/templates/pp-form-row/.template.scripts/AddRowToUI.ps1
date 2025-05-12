﻿$entityXmlPath = (Resolve-Path './SolutionDeclarationsRoot/Entities/exampleentityname/FormXml/formtypeexample/{formguididexample}.xml').Path
$rowPath = (Resolve-Path './.template.temp/row.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$rowsNode = $entityXml.SelectSingleNode('//rows')
if (-not $rowsNode) {
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
