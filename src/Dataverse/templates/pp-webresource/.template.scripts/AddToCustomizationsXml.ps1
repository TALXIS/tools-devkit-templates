# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Customizations.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//ImportExportXml")

# Ensure WebResources node exists once; add only if missing
$existingWebResources = $File.SelectSingleNode("//ImportExportXml/WebResources")
if (-not $existingWebResources) {
    $newComponent = $File.CreateElement("WebResources")
    # Append the new component to the root components without writing output to console
    $null = $rootComponents.AppendChild($newComponent)
    # Save the updated XML back to the file
    $File.Save($solutionPath)
}



