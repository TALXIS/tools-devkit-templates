$ErrorActionPreference = 'Stop'

$ribbonXmlRaw = './__solution-root-path__/Entities/__entity-logical-name__/RibbonDiff.xml'

# Create empty RibbonDiff.xml if entity was scaffolded without one (e.g., Existing behavior)
if (-not (Test-Path $ribbonXmlRaw)) {
    $emptyRibbon = @'
<?xml version="1.0" encoding="utf-8"?>
<RibbonDiffXml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <CustomActions />
  <Templates>
    <RibbonTemplates Id="Mscrm.Templates"></RibbonTemplates>
  </Templates>
  <CommandDefinitions />
  <RuleDefinitions>
    <TabDisplayRules />
    <DisplayRules />
    <EnableRules />
  </RuleDefinitions>
  <LocLabels />
</RibbonDiffXml>
'@
    $dir = Split-Path $ribbonXmlRaw
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $ribbonXmlRaw -Value $emptyRibbon -Encoding UTF8
    Write-Host "Created missing RibbonDiff.xml at $ribbonXmlRaw"
}

$ribbonXmlPath = (Resolve-Path $ribbonXmlRaw).Path
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