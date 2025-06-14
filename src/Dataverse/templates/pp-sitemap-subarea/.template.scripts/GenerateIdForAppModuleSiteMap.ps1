$subareaPath  = (Resolve-Path '.template.temp/subarea.xml').Path

[XML]$File = Get-Content -Path $subareaPath -Raw

$XmlText = $File.OuterXml
$modifiedXmlText = $XmlText -replace [Regex]::Escape("subareaidexample"), ([guid]::NewGuid().ToString() -split '-')[0]

[XML]$File = $ModifiedXmlText

$File.Save($subareaPath)