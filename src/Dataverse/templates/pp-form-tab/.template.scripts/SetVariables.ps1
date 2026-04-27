$tabXmlPath = './.template.temp/tab.xml'
$tabId = "tabexampleid"
$name = "exampletabdisplayname"

if ($tabId -eq "unknownTabId") {
    $tabId = [System.Guid]::NewGuid().ToString()
}

$processedName = $name.ToLower() -replace '[^a-z0-9]', ''

$tabXmlContent = Get-Content -Path $tabXmlPath -Raw
$tabXmlContent = $tabXmlContent -replace 'tabexampleid', $tabId
$tabXmlContent = $tabXmlContent -replace 'exampletabname', $processedName
Set-Content -Path $tabXmlPath -Value $tabXmlContent