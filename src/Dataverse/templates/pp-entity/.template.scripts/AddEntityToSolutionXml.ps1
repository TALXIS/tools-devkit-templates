$ErrorActionPreference = 'Stop'

# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$schemaName = 'examplepublisherprefix_examplecustomentity'
$behavior = 'behaviorType'

# Exports may write the schema name in mixed case (ev_Product), so compare case-insensitively
$existing = @($rootComponents.SelectNodes("RootComponent[@type='1']") | Where-Object { $_.GetAttribute('schemaName') -ieq $schemaName })
if ($existing.Count -gt 0) {
    if ($existing | Where-Object { $_.GetAttribute('behavior') -eq $behavior }) {
        Write-Warning "'$schemaName' is already in Solution.xml RootComponents with behavior $behavior, nothing to add."
        exit 0
    }

    if ($behavior -eq '2') {
        Write-Error "'$schemaName' is already defined in this project. Behavior=Existing is for a table owned by another solution project; add forms, views or columns directly."
        exit 1
    }

    Write-Error "'$schemaName' is already referenced in this project with Behavior=Existing. Remove that reference before defining the table here."
    exit 1
}

# Create a new component element
$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '1')
$newComponent.SetAttribute("schemaName", $schemaName)
$newComponent.SetAttribute("behavior", $behavior)

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
$File.Save($solutionPath)
