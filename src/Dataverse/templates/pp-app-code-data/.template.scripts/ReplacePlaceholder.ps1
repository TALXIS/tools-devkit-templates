param(
    [Parameter(Mandatory)][string]$FilePath,
    [Parameter(Mandatory)][string]$Placeholder,
    [Parameter(Mandatory)][string]$Replacement
)

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
    Rename-Item -Path $FilePath -NewName $newName

    Write-Host "Renamed file: $fileName -> $newName"
} 
else 
{
    Write-Host "Placeholder not found in file name."
}
