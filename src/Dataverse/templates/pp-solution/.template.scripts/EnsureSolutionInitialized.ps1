# Run solution initialization only if key solution artifacts are missing.

$requiredFiles = @(
    'Customizations.xml',
    'Relationships.xml',
    'Solution.xml'
)

$missing = @()

foreach ($file in $requiredFiles) {
    $found = Get-ChildItem -Path . -Recurse -File -Filter $file -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $found) {
        $missing += $file
    }
}

# Find the Solution.xml file and read it as XML
$solutionXml = Get-ChildItem -Path . -Filter Solution.xml -Recurse | Select-Object -First 1
[xml]$xml = Get-Content $solutionXml.FullName -Raw

# Find the UniqueName element and sanitize it
$uniqueName = $xml.ImportExportXml.SolutionManifest.UniqueName
$sanitized = [regex]::Replace($uniqueName, '[^a-zA-Z0-9]', '')
$xml.ImportExportXml.SolutionManifest.UniqueName = $sanitized

# Switch solution type to both to support packing managed solutions using SolutionPackager
$xml.ImportExportXml.SolutionManifest.Managed = 2

# Save the updated XML back to the file
$xml.Save($solutionXml.FullName)

if ($missing.Count -eq 0) {
    Write-Host "Solution artifacts already present (Customizations.xml, Relationships.xml, Solution.xml). Skipping InitializeSolution."
    return
}

Write-Host "Missing solution artifacts: $($missing -join ', '). Running InitializeSolution..."
& (Join-Path $PSScriptRoot 'InitializeSolution.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Error "InitializeSolution.ps1 failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
