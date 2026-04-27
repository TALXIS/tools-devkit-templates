$tabId = "tabexampleid"
$tabNumber = "tabnumberexample"
$setToTabFooter = "settotabfooterchoice"
$entityXmlPath = ./.template.scripts/LocateForm.ps1

$tabPath = (Resolve-Path './.template.temp/column.xml').Path

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
} elseif ($tabId -ne "unknown") {
    $targetTab = $entityXml.SelectSingleNode("//tab[@id='{$tabId}']")
} elseif ($tabNumber -ne "unknown") {
    $tabs = $entityXml.SelectNodes("//tab")
    if ($tabs.Count -ge [int]$tabNumber) {
        $targetTab = $tabs[[int]$tabNumber - 1]
    }
} else {
    $tabs = $entityXml.SelectNodes("//tab")
    if ($tabs.Count -gt 0) {
        $targetTab = $tabs[$tabs.Count - 1]
    }
}

if (-not $targetTab) {
    Write-Error "Target tab not found"
    exit 1
}

#Select tab footer
if ($setToTabFooter -eq "True") {
    $targetTabFooter = $targetTab.SelectSingleNode("//tabfooter[@id='{$tabFooterId}']")

    if (-not $targetTabFooter) {
        $tabFooters = $targetTab.SelectNodes("//tabfooter")
        if ($tabFooters.Count -gt 0) {
            $targetTabFooter = $tabFooters[$tabFooters.Count - 1]
        }
    }

    if (-not $targetTabFooter) {
        Write-Error "Target tab footer not found"
        exit 1
    }

    $targetTab = $targetTabFooter
}

$columnsNode = $targetTab.SelectSingleNode('./columns')
if (-not $columnsNode) {
    $columnsNode = $entityXml.CreateElement("columns")
    $targetTab.AppendChild($columnsNode) | Out-Null
}

$columnRaw = Get-Content -Path $tabPath -Raw
$wrapped = "<columns>$columnRaw</columns>"
[xml]$newcolumnsXml = $wrapped

foreach ($column in $newcolumnsXml.columns.ChildNodes) {
    $imported = $entityXml.ImportNode($column, $true)
    $columnsNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()