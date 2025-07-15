# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Solution.xml'
$filePath = "webresourcefilepathexample"

$fileName = [System.IO.Path]::GetFileName($filePath)

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '61')
$newComponent.SetAttribute("schemaName", "examplepublisher_$fileName")
$newComponent.SetAttribute("behavior", '0')

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
$File.Save($solutionPath)

