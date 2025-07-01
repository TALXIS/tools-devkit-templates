# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Solution.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$webResourcesPath = (Resolve-Path 'SolutionDeclarationsRoot/WebResources').Path
$pathToFunction = Get-ChildItem -Path $webResourcesPath -File | Where-Object { [System.IO.Path]::GetExtension($_.Name) -eq "" } | Select-Object -First 1 | ForEach-Object { $_.FullName }
$libraryname  = [System.IO.Path]::GetFileNameWithoutExtension($pathToFunction)

# Create a new component element
$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '61')
$newComponent.SetAttribute("schemaName", "$libraryname")
$newComponent.SetAttribute("behavior", '0')

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
$File.Save($solutionPath)
