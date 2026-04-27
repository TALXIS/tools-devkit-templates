$entityXmlPath = ./.template.scripts/LocateForm
$paramName = "nameexample"
$paramType = "typeexample"

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$formNode = $entityXml.SelectSingleNode('//form')
if (-not $formNode) {
    exit 1
}

$formParametersNode = $formNode.SelectSingleNode('formparameters')
if (-not $formParametersNode) {
    $formParametersNode = $entityXml.CreateElement('formparameters')
    $formNode.AppendChild($formParametersNode) | Out-Null
}

$existing = $formParametersNode.SelectSingleNode("querystringparameter[@name='$paramName']")

if (-not $existing) {
    $newParam = $entityXml.CreateElement('querystringparameter')

    $nameAttribute = $entityXml.CreateAttribute('name')
    $nameAttribute.Value = $paramName
    [void]$newParam.Attributes.Append($nameAttribute)

        
    $typeAttribute = $entityXml.CreateAttribute('type')
    $typeAttribute.Value = $paramType
    [void]$newParam.Attributes.Append($typeAttribute)

    $formParametersNode.AppendChild($newParam) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()