$ErrorActionPreference = 'Stop'

$formulasDir = (Resolve-Path '__solution-root-path__/Entities/__entity-schema-name__/Formulas' -ErrorAction SilentlyContinue)?.Path
$yamlPath    = Join-Path ($formulasDir ?? (Join-Path '__solution-root-path__' 'Entities' '__entity-schema-name__' 'Formulas')) '__entity-schema-name__-FormulaDefinitions.yaml'
$entryKey    = '__attribute-schema-name__:'

# Create directory if it doesn't exist
if (-not (Test-Path (Split-Path $yamlPath))) {
    New-Item -ItemType Directory -Path (Split-Path $yamlPath) -Force | Out-Null
}

if (Test-Path $yamlPath) {
    # File exists — check if this attribute's entry is already present
    $content = Get-Content $yamlPath -Raw
    $escapedKey = [regex]::Escape($entryKey)
    if ($content -notmatch "(^|`n)$escapedKey") {
        # Append new placeholder entry for the user to fill in
        Add-Content -Path $yamlPath -Value "${entryKey} "
        Write-Host "Appended formula placeholder for '$entryKey' in '$yamlPath'. Fill in the Power Fx expression after the colon."
    } else {
        Write-Host "Formula entry for '$entryKey' already exists in '$yamlPath'. Skipping."
    }
} else {
    # File doesn't exist — create it with the first placeholder entry
    Set-Content -Path $yamlPath -Value "${entryKey} "
    Write-Host "Created '$yamlPath' with formula placeholder for '$entryKey'. Fill in the Power Fx expression after the colon."
}
