$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

$filePath = ".template.scripts/FlowWorkflowID.txt"
$WorkflowId = (Get-Content -Path $filePath -Raw).Trim()

[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '29')
$newComponent.SetAttribute("id", "{$WorkflowId}")
$newComponent.SetAttribute("behavior", '0')

$null = $rootComponents.AppendChild($newComponent)

$File.Save($solutionPath)
