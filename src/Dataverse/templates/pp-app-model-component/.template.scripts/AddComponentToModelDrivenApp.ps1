# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot\AppModuleSiteMaps\userprefixexample_appexemplename/AppModule.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//AppModuleComponents")

$newComponent = $File.CreateElement("AppModuleComponent")
$newComponent.SetAttribute("type", 'entitytypeexemple')
$newComponent.SetAttribute("schemaName", 'userprefixexample_appexemplename')

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
$File.Save($solutionPath)