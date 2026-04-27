$tabId = "tabexampleid"
$tabNumber = "tabnumberexample"
$columnNumber = "columnnumberexample"
$sectionId = "sectionidexample"
$sectionNumber = "sectionnumberexample"
$rowNumber = "rownumberexample"
$entityXmlPath = ./.template.scripts/LocateForm.ps1

$parameterPath = (Resolve-Path './.template.temp/parameters.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$targetTab = $null

if ($tabId -ne "unknown" -and $tabNumber -ne "unknown") {
    $targetTab = $entityXml.SelectSingleNode("//tab[@id='{$tabId}']")
    if (-not $targetTab) {
        $tabs = $entityXml.SelectNodes("//tab")
        if ($tabs.Count -ge [int]$tabNumber) {
            $targetTab = $tabs[[int]$tabNumber - 1]
        }
    }
}
elseif ($tabId -ne "unknown") {
    $targetTab = $entityXml.SelectSingleNode("//tab[@id='{$tabId}']")
}
elseif ($tabNumber -ne "unknown") {
    $tabs = $entityXml.SelectNodes("//tab")
    if ($tabs.Count -ge [int]$tabNumber) {
        $targetTab = $tabs[[int]$tabNumber - 1]
    }
}
else {
    $tabs = $entityXml.SelectNodes("//tab")
    if ($tabs.Count -gt 0) {
        $targetTab = $tabs[$tabs.Count - 1]
    }
}

if (-not $targetTab) {
    Write-Error "Target tab not found"
    exit 1
}

<!--#if (SetToTabFooter == "True") -->

#Select tab footer
$targetTabFooter = $null

if (-not $targetTabFooter) {
    $tabFooters = $targetTab.SelectNodes("./tabfooter")

    if ($tabFooters -and $tabFooters.Count -gt 0) {
        $targetTabFooter = $tabFooters[$tabFooters.Count - 1]
    }
}

if (-not $targetTabFooter) {
    Write-Error "Target tab footer not found"
    exit 1
}

$targetTab = $targetTabFooter
<!--#endif -->
$targetColumn = $null

if ($columnNumber -ne "unknown") {
    $columns = $targetTab.SelectNodes('./columns/column')
    if ($columns.Count -ge [int]$columnNumber) {
        $targetColumn = $columns[[int]$columnNumber - 1]
    }
}
else {
    $columns = $targetTab.SelectNodes('./columns/column')
    if ($columns.Count -gt 0) {
        $targetColumn = $columns[$columns.Count - 1]
    }
}

if (-not $targetColumn) {
    Write-Error "Target column not found in the selected tab"
    exit 1
}

$targetSection = $null

if ($sectionId -ne "unknown" -and $sectionNumber -ne "unknown") {
    $targetSection = $targetColumn.SelectSingleNode("./sections/section[@id='{$sectionId}']")
    if (-not $targetSection) {
        $sections = $targetColumn.SelectNodes('./sections/section')
        if ($sections.Count -ge [int]$sectionNumber) {
            $targetSection = $sections[[int]$sectionNumber - 1]
        }
    }
}
elseif ($sectionId -ne "unknown") {
    $targetSection = $targetColumn.SelectSingleNode("./sections/section[@id='{$sectionId}']")
}
elseif ($sectionNumber -ne "unknown") {
    $sections = $targetColumn.SelectNodes('./sections/section')
    if ($sections.Count -ge [int]$sectionNumber) {
        $targetSection = $sections[[int]$sectionNumber - 1]
    }
}
else {
    $sections = $targetColumn.SelectNodes('./sections/section')
    if ($sections.Count -gt 0) {
        $targetSection = $sections[$sections.Count - 1]
    }
}

if (-not $targetSection) {
    Write-Error "Target section not found in the selected column"
    exit 1
}

$targetRow = $null

if ($rowNumber -ne "unknown") {
    $rows = $targetSection.SelectNodes('./rows/row')
    if ($rows.Count -ge [int]$rowNumber) {
        $targetRow = $rows[[int]$rowNumber - 1]
    }
}
else {
    $rows = $targetSection.SelectNodes('./rows/row')
    if ($rows.Count -gt 0) {
        $targetRow = $rows[$rows.Count - 1]
    }
}

if (-not $targetRow) {
    Write-Error "Target row not found in the selected section"
    exit 1
}

$existingCell = $targetRow.SelectSingleNode('./cell')
if (-not $existingCell) {
    Write-Error "No existing cell found in the target row"
    exit 1
}

$controlNode = $existingCell.SelectSingleNode('./control')
if ($controlNode -and $parameterPath) {
    [xml]$parameterXml = Get-Content -Path $parameterPath -Raw
    
    $parametersNode = $entityXml.CreateElement("parameters")
    
    foreach ($paramNode in $parameterXml.parameters.ChildNodes) {
        $importedParam = $entityXml.ImportNode($paramNode, $true)
        $parametersNode.AppendChild($importedParam) | Out-Null
    }
    
    $controlNode.AppendChild($parametersNode) | Out-Null
}
else {
    Write-Error "Control node not found in existing cell or parameter path is empty"
    exit 1
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()