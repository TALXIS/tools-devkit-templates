$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

# The engine substitutes the same GUID it wrote into this flow's data.xml,
# so no directory lookup is needed (picking the first *.data.xml registered
# the wrong flow when the solution already contained other flows).
$WorkflowId = '{__flow-workflow-id__}'

[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

if ($null -eq $rootComponents.SelectSingleNode("RootComponent[@id='$WorkflowId']")) {
    $newComponent = $File.CreateElement("RootComponent")
    $newComponent.SetAttribute("type", '29')
    $newComponent.SetAttribute("id", $WorkflowId)
    $newComponent.SetAttribute("behavior", '0')

    $null = $rootComponents.AppendChild($newComponent)

    $File.Save($solutionPath)
}
