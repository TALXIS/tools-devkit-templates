. "$PSScriptRoot/Save-TxcXml.ps1"

$dialogsRootPath = '__solution-root-path__/Dialogs\{formexampleId}.xml'
$formName = 'formexamplename'
$EntitySchemaName = 'ItemFolderName'

$uniqueNameFull

if ("dialogexampleuniquename" -eq "unknown") {
    $prefix = $EntitySchemaName.Split('_')[0]
    $UniqueName = $formName -replace '[^\w]', '' | ForEach-Object { $_.ToLower() }
    $uniqueNameFull =$prefix + "_" + $UniqueName + "dialog"
}
else {
    $uniqueNameFull = "dialogexampleuniquename"
}


[xml]$xmlDoc = Get-Content -Path $dialogsRootPath -Raw

$uniqueNameNode = $xmlDoc.SelectSingleNode("//UniqueName")

if ($uniqueNameNode) {
    $uniqueNameNode.InnerText = $uniqueNameFull
    
    Save-TxcXml -Document $xmlDoc -Path $dialogsRootPath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')
    Write-Host "Value updated successfully"
}
else {
    Write-Host "Node UniqueName not found"
}