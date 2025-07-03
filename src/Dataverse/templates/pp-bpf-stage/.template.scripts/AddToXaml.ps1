$targetXamlFolderPath = (Resolve-Path 'SolutionDeclarationsRoot\Workflows').Path
$stageXamlPath = (Resolve-Path '.template.temp\stage.xaml').Path

$targetXamlFile = Get-ChildItem -Path $targetXamlFolderPath -Recurse -Filter *.xaml | Select-Object -First 1

if (-not $targetXamlFile) {
    Write-Host "XAML-файл не найден!"
    exit 1
}

[xml]$targetXml = Get-Content -Path $targetXamlFile.FullName -Raw
[xml]$stageXml = Get-Content -Path $stageXamlPath -Raw

$workflowNode = $targetXml.SelectSingleNode('//*[local-name()="Workflow"]')

if (-not $workflowNode) {
    exit 1
}

foreach ($child in $stageXml.DocumentElement.ChildNodes) {
    $imported = $targetXml.ImportNode($child, $true)
    $workflowNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($targetXamlFile.FullName, $settings)
$targetXml.Save($writer)
$writer.Close()