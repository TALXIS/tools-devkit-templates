. "$PSScriptRoot/Save-TxcXml.ps1"

$ErrorActionPreference = 'Stop'

# Solution.xml lives next to Other/ inside the unpacked solution root. If the project doesn't
# carry a Solution.xml (some setups manage Solution.xml separately or assemble it at pack time),
# skip registration silently — the definition folder on disk is sufficient for packagers that
# scan the source tree.
$solutionXmlPath = '__solution-root-path__/Other/Solution.xml'
if (-not (Test-Path $solutionXmlPath)) {
    Write-Host "Solution.xml not found at $solutionXmlPath — skipping RootComponent registration."
    return
}

$resolvedPath = (Resolve-Path -Path $solutionXmlPath).Path

[xml]$file = Get-Content -Path $resolvedPath -Raw
$rootComponents = $file.SelectSingleNode("//RootComponents")
if ($null -eq $rootComponents) {
    Write-Host "<RootComponents> node missing in Solution.xml — skipping registration."
    return
}

$schemaName = '__schema-name__'

# Idempotent: only add when not already present.
$existing = $rootComponents.SelectSingleNode("RootComponent[@type='380' and @schemaName='$schemaName']")
if ($null -ne $existing) {
    Write-Host "Environment variable definition '$schemaName' already registered in Solution.xml."
    return
}

$newComponent = $file.CreateElement("RootComponent")
$newComponent.SetAttribute("type", "380")
$newComponent.SetAttribute("schemaName", $schemaName)
$newComponent.SetAttribute("behavior", "0")

$null = $rootComponents.AppendChild($newComponent)
Save-TxcXml -Document $file -Path $resolvedPath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')
