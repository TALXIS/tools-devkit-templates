$targetXamlFolderPath = (Resolve-Path 'SolutionDeclarationsRoot\Workflows').Path
$stageXamlPath = (Resolve-Path '.template.temp\stage.xaml').Path

$targetXamlFile = Get-ChildItem -Path $targetXamlFolderPath -Recurse -Filter *.xaml | Select-Object -First 1

if (-not $targetXamlFile) {
    exit 1
}

[xml]$targetXml = Get-Content $targetXamlFile -Raw

$stageText = Get-Content $stageXamlPath -Raw

$xmlHeader = '<root xmlns:mxswa="clr-namespace:Microsoft.Crm.Workflow.Activities;assembly=Microsoft.Crm.Workflow" xmlns:sco="clr-namespace:System.Collections.ObjectModel;assembly=mscorlib" xmlns:mcwo="clr-namespace:Microsoft.Crm.Workflow.Objects;assembly=Microsoft.Crm.Workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">'
$xmlFooter = '</root>'
$stageXmlFull = $xmlHeader + $stageText + $xmlFooter

[xml]$stageXml = $stageXmlFull

$workflowNode = $targetXml.SelectSingleNode('//*[local-name()="Workflow"]')

foreach ($child in $stageXml.DocumentElement.ChildNodes) {
    $imported = $targetXml.ImportNode($child, $true)
    $workflowNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($targetXamlFile, $settings)
$targetXml.Save($writer)
$writer.Close()