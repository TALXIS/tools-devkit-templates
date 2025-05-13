$areaPath  = (Resolve-Path '.template.temp/area.xml').Path

[XML]$File = Get-Content -Path $areaPath -Raw

$XmlText = $File.OuterXml
$modifiedXmlText = $XmlText -replace [Regex]::Escape("areaidexample"), ([guid]::NewGuid().ToString() -split '-')[0]

[XML]$File = $ModifiedXmlText

$File.Save($areaPath)