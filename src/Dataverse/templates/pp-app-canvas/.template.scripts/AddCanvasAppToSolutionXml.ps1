$ErrorActionPreference = 'Stop'

# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$schemaName = '__publisher-prefix-default-value___logicalnameexample_numericsuffixexample'

# Skip if already present (e.g. user ran the template twice in the same project)
$existing = $rootComponents.SelectSingleNode("RootComponent[@type='300' and @schemaName='$schemaName']")
if (-not $existing) {
    $newComponent = $File.CreateElement("RootComponent")
    $newComponent.SetAttribute("type",       '300')
    $newComponent.SetAttribute("schemaName", $schemaName)
    $newComponent.SetAttribute("behavior",   '0')

    $null = $rootComponents.AppendChild($newComponent)
    $File.Save($solutionPath)
}
