$baseDir = "SolutionDeclarationsRoot\AppModuleSiteMaps"

$fileName = "AppModuleSiteMap.xml"

$file = Get-ChildItem -Path $baseDir -Filter $fileName -Recurse -File | Select-Object -First 1

$siteMapPath = $file.FullName

[XML]$File = Get-Content -Path $siteMapPath -Raw

$XmlText = $File.OuterXml
$modifiedXmlText = $XmlText -replace [Regex]::Escape("areaidexemple"), ([guid]::NewGuid().ToString() -split '-')[0]
$modifiedXmlText = $modifiedXmlText -replace [Regex]::Escape("groupidexemple"), ([guid]::NewGuid().ToString() -split '-')[0]
$modifiedXmlText = $modifiedXmlText -replace [Regex]::Escape("subareaidexemple"), ([guid]::NewGuid().ToString() -split '-')[0]

[XML]$File = $ModifiedXmlText

$File.Save($siteMapPath)