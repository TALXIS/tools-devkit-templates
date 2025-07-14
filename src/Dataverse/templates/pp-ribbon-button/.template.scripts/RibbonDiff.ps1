﻿$ribbonXmlPath = (Resolve-Path './SolutionDeclarationsRoot/Entities/exampleentityname/RibbonDiff.xml').Path
$commanddefinitionPath = (Resolve-Path './.template.temp/commanddefinition.xml').Path
$loclbelsPath = (Resolve-Path './.template.temp/loclbels.xml').Path
$customactionPath = (Resolve-Path './.template.temp/customaction.xml').Path

[xml]$ribbonXml = Get-Content $ribbonXmlPath -Raw

function Add-XmlContent {
    param (
        [xml]$parentXml,
        [string]$nodeName,
        [string]$contentPath
    )
    if (Test-Path $contentPath) {
        [xml]$contentXml = Get-Content $contentPath -Raw
        foreach ($child in $contentXml.DocumentElement.ChildNodes) {
            $imported = $parentXml.ImportNode($child, $true)
            $targetNode = $parentXml.SelectSingleNode("//*[local-name()='$nodeName']")
            if ($targetNode) {
                $targetNode.AppendChild($imported) | Out-Null
            }
        }
    }
}

Add-XmlContent -parentXml $ribbonXml -nodeName "CommandDefinitions" -contentPath $commanddefinitionPath
Add-XmlContent -parentXml $ribbonXml -nodeName "LocLabels" -contentPath $loclbelsPath
Add-XmlContent -parentXml $ribbonXml -nodeName "CustomActions" -contentPath $customactionPath

$ribbonXml.Save($ribbonXmlPath)

