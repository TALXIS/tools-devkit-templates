# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Solution.xml'

$filePath = ".template.scripts\WorkflowsID.txt"

# Read the file content into a variable
$WorkflowId = Get-Content -Path $filePath -Raw
$WorkflowId = $WorkflowId.Trim()
# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '29')
$newComponent.SetAttribute("id", "{$WorkflowId}")
$newComponent.SetAttribute("behavior", '0')

$null = $rootComponents.AppendChild($newComponent)

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '60')
$newComponent.SetAttribute("id", '{mainFormIdexample}')
$newComponent.SetAttribute("behavior", '0')

$null = $rootComponents.AppendChild($newComponent)

$newComponent2 = $File.CreateElement("RootComponent")
$newComponent2.SetAttribute("type", '1')
$newComponent2.SetAttribute("schemaName", 'examplepublisher_examplebpfname')
$newComponent2.SetAttribute("behavior", '0')

$null = $rootComponents.AppendChild($newComponent2)

# Save the updated XML back to the file
$File.Save($solutionPath)
