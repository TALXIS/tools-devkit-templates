. "$PSScriptRoot/Save-TxcXml.ps1"

$groupPath  = (Resolve-Path '.template.temp/group.xml').Path

[XML]$File = Get-Content -Path $groupPath -Raw

$XmlText = $File.OuterXml
$modifiedXmlText = $XmlText -replace [Regex]::Escape("groupidexample"), ([guid]::NewGuid().ToString() -split '-')[0]

[XML]$File = $ModifiedXmlText

Save-TxcXml -Document $File -Path $groupPath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')