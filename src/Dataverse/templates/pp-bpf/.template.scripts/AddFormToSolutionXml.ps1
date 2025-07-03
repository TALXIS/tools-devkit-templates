# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Solution.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '29')
$newComponent.SetAttribute("id", '{mainFormIdexample}')
$newComponent.SetAttribute("behavior", '0')

$null = $rootComponents.AppendChild($newComponent)

$newComponent2 = $File.CreateElement("RootComponent")
$newComponent2.SetAttribute("type", '1')
$newComponent2.SetAttribute("id", 'examplepublisher_examplebpfname')
$newComponent2.SetAttribute("behavior", '0')

$null = $rootComponents.AppendChild($newComponent2)


# Save the updated XML back to the file
$File.Save($solutionPath)


