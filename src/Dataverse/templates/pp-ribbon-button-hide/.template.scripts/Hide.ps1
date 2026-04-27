$action = ".template.temp\customactionstohide.xml"
$ribbonXmlPath = (Resolve-Path './SolutionDeclarationsRoot/Entities/exampleentityname/RibbonDiff.xml').Path

[xml]$ribbonXml = Get-Content $ribbonXmlPath -Raw
[xml]$actionXml = Get-Content $action -Raw

$customActionsNode = $ribbonXml.SelectSingleNode("//CustomActions")
$hideActions = $actionXml.SelectNodes("//HideCustomAction")

if ($hideActions.Count -eq 0) {
    exit 0
}

foreach ($hideAction in $hideActions) {
    $clonedAction = $ribbonXml.ImportNode($hideAction, $true)
    $customActionsNode.AppendChild($clonedAction) | Out-Null
}

$ribbonXml.Save($ribbonXmlPath)