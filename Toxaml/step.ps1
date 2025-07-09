$targetXamlFolderPath = (Resolve-Path 'SolutionDeclarationsRoot\Workflows').Path
$stepXamlPath = (Resolve-Path '.template.temp\step.xaml').Path

$targetXamlFile = Get-ChildItem -Path $targetXamlFolderPath -Recurse -Filter *.xaml | Select-Object -First 1

if (-not $targetXamlFile) {
    exit 1
}

[xml]$targetXml = Get-Content $targetXamlFile -Raw

$stepText = Get-Content $stepXamlPath -Raw

$xmlHeader = '<root xmlns:mxswa="clr-namespace:Microsoft.Crm.Workflow.Activities;assembly=Microsoft.Crm.Workflow" xmlns:sco="clr-namespace:System.Collections.ObjectModel;assembly=mscorlib" xmlns:mcwo="clr-namespace:Microsoft.Crm.Workflow.Objects;assembly=Microsoft.Crm.Workflow" xmlns:mcwb="clr-namespace:Microsoft.Crm.Workflow.BusinessEntities;assembly=Microsoft.Crm.Workflow" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">'
$xmlFooter = '</root>'
$stepXmlFull = $xmlHeader + $stepText + $xmlFooter

# Загружаем как XML
[xml]$stepXml = $stepXmlFull

$nsMgr = New-Object System.Xml.XmlNamespaceManager($targetXml.NameTable)
$nsMgr.AddNamespace("mxswa", "clr-namespace:Microsoft.Crm.Workflow.Activities;assembly=Microsoft.Crm.Workflow")
$nsMgr.AddNamespace("sco", "clr-namespace:System.Collections.ObjectModel;assembly=mscorlib")
$nsMgr.AddNamespace("mcwo", "clr-namespace:Microsoft.Crm.Workflow.Objects;assembly=Microsoft.Crm.Workflow")
$nsMgr.AddNamespace("mcwb", "clr-namespace:Microsoft.Crm.Workflow.BusinessEntities;assembly=Microsoft.Crm.Workflow")
$nsMgr.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml")

# Находим ActivityReference
$activityRefNode = $targetXml.SelectSingleNode('//mxswa:ActivityReference[@DisplayName="stageexamplename"]', $nsMgr)

if (-not $activityRefNode) {
    Write-Error "ActivityReference with required DisplayName not found"
    exit 1
}

# Находим коллекцию Activities внутри ActivityReference
$activitiesNode = $activityRefNode.SelectSingleNode('.//sco:Collection[@x:Key="Activities"]', $nsMgr)

if (-not $activitiesNode) {
    Write-Error "Collection with x:Key='Activities' not found inside the required ActivityReference"
    exit 1
}

foreach ($child in $stepXml.DocumentElement.ChildNodes) {
    $imported = $targetXml.ImportNode($child, $true)
    $activitiesNode.AppendChild($imported) | Out-Null
}

# Сохраняем результат
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($targetXamlFile, $settings)
$targetXml.Save($writer)
$writer.Close()