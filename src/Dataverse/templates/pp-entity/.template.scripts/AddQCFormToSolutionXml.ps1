. "$PSScriptRoot/Save-TxcXml.ps1"

# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '60')
$newComponent.SetAttribute("id", '{quickCreateFormId}')
$newComponent.SetAttribute("behavior", '0')

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
Save-TxcXml -Document $File -Path $solutionPath

