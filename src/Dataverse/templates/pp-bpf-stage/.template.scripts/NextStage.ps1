. "$PSScriptRoot/Save-TxcXml.ps1"

$guidValue = "stageexampleid"

$targetXamlFolderPath = (Resolve-Path '__solution-root-path__/Workflows').Path

$targetXamlFile = Get-ChildItem -Path $targetXamlFolderPath -Recurse -Filter *.xaml | Select-Object -First 1

[xml]$xml = Get-Content $targetXamlFile -Raw

$nsMgr = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$nsMgr.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml")

$nextStageNode = $xml.SelectSingleNode('//x:Null[@x:Key="NextStageId"]', $nsMgr)

if ($nextStageNode) {
    if ([string]::IsNullOrWhiteSpace($nextStageNode.InnerText)) {
        $nextStageNode.InnerText = $guidValue
        Save-TxcXml -Document $xml -Path $targetXamlFile -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')
    }
} else {
    Write-Host "Node <x:String x:Key='NextStageId'> was not found."
}