# Resolve the relative path to an absolute path (to support other OSes)
# Try both naming conventions (with and without _managed suffix)
$candidatePath = 'SolutionDeclarationsRoot/AppModules/appexamplename/AppModule.xml'
$candidatePathManaged = 'SolutionDeclarationsRoot/AppModules/appexamplename/AppModule_managed.xml'
if (Test-Path $candidatePath) {
    $solutionPath = Resolve-Path -Path $candidatePath
} elseif (Test-Path $candidatePathManaged) {
    $solutionPath = Resolve-Path -Path $candidatePathManaged
} else {
    Write-Warning "No AppModule XML found — skipping component registration"
    exit 0
}

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//AppModuleComponents")

$newComponent = $File.CreateElement("AppModuleComponent")
$newComponent.SetAttribute("type", 'entitytypeexample')

if ( "entitytypeexample" -eq "1") {
    $newComponent.SetAttribute("schemaName", 'entityexamplename')
}
else {
    $newComponent.SetAttribute("id", '{appmodelcomponentidexample}')
}

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
$File.Save($solutionPath)