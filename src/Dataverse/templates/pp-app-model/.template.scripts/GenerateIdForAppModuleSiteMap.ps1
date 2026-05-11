$baseDir = "__solution-root-path__/AppModuleSiteMaps"

# Try both naming conventions (with and without _managed suffix)
$file = Get-ChildItem -Path $baseDir -Filter "AppModuleSiteMap.xml" -Recurse -File | Select-Object -First 1
if (-not $file) {
    $file = Get-ChildItem -Path $baseDir -Filter "AppModuleSiteMap_managed.xml" -Recurse -File | Select-Object -First 1
}
if (-not $file) {
    Write-Warning "No AppModuleSiteMap XML found in $baseDir — skipping ID generation"
    exit 0
}

$siteMapPath = $file.FullName

[XML]$File = Get-Content -Path $siteMapPath -Raw

$XmlText = $File.OuterXml
$modifiedXmlText = $XmlText -replace [Regex]::Escape("areaidexample"), ([guid]::NewGuid().ToString() -split '-')[0]
$modifiedXmlText = $modifiedXmlText -replace [Regex]::Escape("groupidexample"), ([guid]::NewGuid().ToString() -split '-')[0]
$modifiedXmlText = $modifiedXmlText -replace [Regex]::Escape("subareaidexample"), ([guid]::NewGuid().ToString() -split '-')[0]

[XML]$File = $ModifiedXmlText

$File.Save($siteMapPath)