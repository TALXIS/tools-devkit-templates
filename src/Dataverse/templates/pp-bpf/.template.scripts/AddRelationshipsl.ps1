# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Relationships.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//EntityRelationships")

$newComponent = $File.CreateElement("EntityRelationship")
$newComponent.SetAttribute("Name", 'bpf_primaryentityexample_examplepublisher_examplebpfname')

$null = $rootComponents.AppendChild($newComponent)

$null = $rootComponents.AppendChild($newComponent2)

# Save the updated XML back to the file
$File.Save($solutionPath)
