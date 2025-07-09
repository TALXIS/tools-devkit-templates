$targetXmlFolderPath = (Resolve-Path 'SolutionDeclarationsRoot\Workflows').Path
$steplabelsPath = (Resolve-Path '.template.temp\steplabels.xml').Path

$targetXmlFile = Get-ChildItem -Path $targetXmlFolderPath -Recurse -Filter *.xml | Select-Object -First 1

if (-not $targetXmlFile) {
    exit 1
}

[xml]$targetXml = Get-Content -Path $targetXmlFile.FullName -Raw
[xml]$steplabelsXml = Get-Content -Path $steplabelsPath -Raw

$imported = $targetXml.ImportNode($steplabelsXml.DocumentElement, $true)
$targetXml.DocumentElement.AppendChild($imported) | Out-Null

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($targetXmlFile.FullName, $settings)
$targetXml.Save($writer)
$writer.Close()