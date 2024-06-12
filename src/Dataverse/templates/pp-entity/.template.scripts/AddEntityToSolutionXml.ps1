# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Solution.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

# Create a new component element
$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '1')
$newComponent.SetAttribute("schemaName", 'examplepublisherprefix_examplecustomentity')
$newComponent.SetAttribute("behavior", 'behaviorType')

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
$File.Save($solutionPath)
