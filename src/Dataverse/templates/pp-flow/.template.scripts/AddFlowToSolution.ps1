$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

# Extract the workflow GUID from the generated .json.data.xml
# The template engine replaces __flow-workflow-id__ with a real GUID
$dataXml = Get-ChildItem -Path '__solution-root-path__/Workflows' -Filter '*.json.data.xml' | Select-Object -First 1
if (-not $dataXml) {
    Write-Error "No .json.data.xml found in Workflows directory"
    exit 1
}

# Parse WorkflowId from the data.xml content
[XML]$flowData = Get-Content -Path $dataXml.FullName -Raw
$WorkflowId = $flowData.Workflow.WorkflowId

[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '29')
$newComponent.SetAttribute("id", $WorkflowId)
$newComponent.SetAttribute("behavior", '0')

$null = $rootComponents.AppendChild($newComponent)

$File.Save($solutionPath)
