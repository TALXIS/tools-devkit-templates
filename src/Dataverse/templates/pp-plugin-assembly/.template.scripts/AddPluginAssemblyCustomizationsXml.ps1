# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path './SolutionDeclarationsRoot/Other/Customizations.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//ImportExportXml")

$existingComponent = $rootComponents.SelectSingleNode("SolutionPluginAssemblies")

if ($null -eq $existingComponent) {
    $newComponent = $File.CreateElement("SolutionPluginAssemblies")
    $null = $rootComponents.AppendChild($newComponent)
    
    # Save the updated XML back to the file
    $File.Save($solutionPath)
} 