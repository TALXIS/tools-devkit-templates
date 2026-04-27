$entityXmlPath = ./.template.scripts/LocateForm.ps1
$controlDescriptionId = "controlDescriptionIdexample"
$customControlFormFactor="customcontrolformfactorexample"
$customControlName="examplepublisherprefix_customcontrolnameexample"

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$parameterPath = (Resolve-Path './.template.temp/customcontrolparameters.xml').Path

$formNode = $entityXml.SelectSingleNode("//form")
if (-not $formNode) {
    Write-Error "Form node not found"
    exit 1
}

$controlDescriptionsNode = $formNode.SelectSingleNode("./controlDescriptions")
if (-not $controlDescriptionsNode) {
    $controlDescriptionsNode = $entityXml.CreateElement("controlDescriptions")
    $formNode.AppendChild($controlDescriptionsNode) | Out-Null
}

$controlDescriptionNode = $controlDescriptionsNode.SelectSingleNode("./controlDescription[@forControl='{$controlDescriptionId}']")
if (-not $controlDescriptionNode) {
    $controlDescriptionNode = $entityXml.CreateElement("controlDescription")
    $controlDescriptionNode.SetAttribute("forControl", "{$controlDescriptionId}")
    $controlDescriptionsNode.AppendChild($controlDescriptionNode) | Out-Null
}

$customControlNode = $controlDescriptionNode.SelectSingleNode("./customControl[@formFactor='$customControlFormFactor' and @name='$customControlName']")
if (-not $customControlNode) {
    $customControlNode = $entityXml.CreateElement("customControl")
    $customControlNode.SetAttribute("formFactor", $customControlFormFactor)
    $customControlNode.SetAttribute("name", $customControlName)
    $controlDescriptionNode.AppendChild($customControlNode) | Out-Null
    
    $parametersNode = $entityXml.CreateElement("parameters")
    $customControlNode.AppendChild($parametersNode) | Out-Null
} else {
    $parametersNode = $customControlNode.SelectSingleNode("./parameters")
    if (-not $parametersNode) {
        $parametersNode = $entityXml.CreateElement("parameters")
        $customControlNode.AppendChild($parametersNode) | Out-Null
    }
}

if (Test-Path $parameterPath) {
    [xml]$parameterXml = Get-Content -Path $parameterPath -Raw
    $importedParameter = $entityXml.ImportNode($parameterXml.DocumentElement, $true)
    $parametersNode.AppendChild($importedParameter) | Out-Null
}

$entityXml.Save($entityXmlPath)