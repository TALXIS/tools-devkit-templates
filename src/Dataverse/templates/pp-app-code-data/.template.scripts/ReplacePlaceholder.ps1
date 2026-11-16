param(
    [Parameter(Mandatory)][string]$FilePath,
    [Parameter(Mandatory)][string]$Placeholder,
    [Parameter(Mandatory)][string]$Replacement
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $FilePath)) 
{
    Write-Error "File not found: $FilePath"
    exit 1
}

# Replace inside file content
$content = Get-Content $FilePath -Raw

if ($content -match [regex]::Escape($Placeholder)) 
{
    $content = $content.Replace($Placeholder, $Replacement)
    Set-Content -Path $FilePath -Value $content -NoNewline

    Write-Host "Replaced placeholder in file content."
} 
else 
{
    Write-Host "Placeholder not found in file content."
}

# Replace in file name
$fileName = Split-Path $FilePath -Leaf

if ($fileName -match [regex]::Escape($Placeholder)) 
{
    $newName = $fileName.Replace($Placeholder, $Replacement)
    $newPath = Join-Path (Split-Path $FilePath -Parent) $newName
    # Move-Item -Force, not Rename-Item: re-running the template for a table that already has
    # its file (a service regenerated after a column was added) must replace it. Rename-Item
    # fails when the target exists, even with -Force, and leaves the placeholder-named copy
    # next to the stale one, a second file declaring the same class (TS2308).
    Move-Item -LiteralPath $FilePath -Destination $newPath -Force

    Write-Host "Renamed file: $fileName -> $newName"
} 
else 
{
    Write-Host "Placeholder not found in file name."
}
