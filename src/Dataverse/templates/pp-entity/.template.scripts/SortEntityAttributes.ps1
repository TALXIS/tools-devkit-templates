$entityDir = Get-ChildItem -Path "SolutionDeclarationsRoot/Entities" -Directory | Select-Object -First 1
if (-not $entityDir) { exit 0 }

$entityXmlPath = Join-Path $entityDir.FullName "Entity.xml"
if (-not (Test-Path $entityXmlPath)) { exit 0 }

[xml]$xml = Get-Content -Path $entityXmlPath -Raw

$attributesNodes = $xml.SelectNodes('//entity/attributes')
foreach ($attributesNode in $attributesNodes) {
    $attrs = @($attributesNode.SelectNodes('attribute'))
    if ($attrs.Count -eq 0) { continue }

    $sorted = $attrs | Sort-Object { $_.GetAttribute('PhysicalName').ToLowerInvariant() }

    foreach ($a in $attrs) {
        $attributesNode.RemoveChild($a) | Out-Null
    }
    foreach ($a in $sorted) {
        $attributesNode.AppendChild($a) | Out-Null
    }
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false
$settings.Encoding = New-Object System.Text.UTF8Encoding($true)

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$xml.Save($writer)
$writer.Close()
