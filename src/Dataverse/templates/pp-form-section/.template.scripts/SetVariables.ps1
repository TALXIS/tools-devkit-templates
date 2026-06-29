$tabXmlPath = './.template.temp/section.xml'
$tabId = "sectionidexample"
$name = "sectionnameexample"

if ($tabId -eq "unknown") {
    $tabId = [System.Guid]::NewGuid().ToString()
}

$processedName = $name.ToLower() -replace '[^a-z0-9]', ''

$tabXmlContent = Get-Content -Path $tabXmlPath -Raw
$tabXmlContent = $tabXmlContent -replace 'sectionidexample', $tabId
$tabXmlContent = $tabXmlContent -replace 'examplesectionname', $processedName
$tabXmlContent = $tabXmlContent.Replace("`r`n", "`n").Replace("`r", "`n")
[System.IO.File]::WriteAllText($tabXmlPath, $tabXmlContent, [System.Text.UTF8Encoding]::new($false))