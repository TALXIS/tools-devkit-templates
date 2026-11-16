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
        if ($tabs.Count -ge [int]$tabNumber -and [int]$tabNumber -ge 1) {
            $targetTab = $tabs[[int]$tabNumber - 1]
        }
    }
} elseif ($tabId -ne "unknown") {
    $targetTab = $entityXml.SelectSingleNode("//tab[@id='{$tabId}']")
} elseif ($tabNumber -ne "unknown") {
    $tabs = $entityXml.SelectNodes("//tab")
    if ($tabs.Count -ge [int]$tabNumber -and [int]$tabNumber -ge 1) {
        $targetTab = $tabs[[int]$tabNumber - 1]
    }
} else {
    $tabs = $entityXml.SelectNodes("//tab")
    if ($tabs.Count -gt 0) {
        $targetTab = $tabs[$tabs.Count - 1]
    }
}

if (-not $targetTab) {
    Write-Error "Target tab not found. TabIndex is 1-based (the first tab is 1)."
    exit 1
}

if ($setToTabFooter -eq "True") {
    # A <tabfooter> holds only <rows> (FormXml XSD, and every built-in dialog
    # footer). Columns there fail `txc workspace validate`, so
    # refuse before the form is touched.
    Write-Error "A tab footer can only contain rows. Add footer buttons with pp-form-row, pp-form-cell and pp-form-control using SetToTabFooter=True."
    exit 1
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