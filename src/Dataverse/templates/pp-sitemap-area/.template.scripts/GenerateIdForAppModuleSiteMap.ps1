. "$PSScriptRoot/Save-TxcXml.ps1"

$areaPath  = (Resolve-Path '.template.temp/area.xml').Path

[XML]$File = Get-Content -Path $areaPath -Raw

$XmlText = $File.OuterXml
$modifiedXmlText = $XmlText -replace [Regex]::Escape("areaidexample"), ([guid]::NewGuid().ToString() -split '-')[0]

[XML]$File = $ModifiedXmlText

Save-TxcXml -Document $File -Path $areaPath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')