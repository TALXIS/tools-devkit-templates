param(
    [Parameter(Mandatory)][string]$TargetString,
    [Parameter(Mandatory)][string]$SettingString,
    [Parameter(Mandatory)][string]$FilePath
)

if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

$lines = [System.IO.File]::ReadAllLines($FilePath)

# Find target line index
$targetIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Contains($TargetString)) {
        $targetIdx = $i
        break
    }
}

if ($targetIdx -eq -1) {
    Write-Error "TargetString not found in file."
    exit 1
}

# Find insert point: first empty line after target (or end of file)
$insertIdx = $lines.Count
for ($i = $targetIdx + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq '') {
        $insertIdx = $i
        break
    }
}

# Build result
$result = [System.Collections.Generic.List[string]]::new()

for ($i = 0; $i -lt $insertIdx; $i++) {
    $result.Add($lines[$i])
}

$result.Add($SettingString)
$result.Add('')

for ($i = $insertIdx; $i -lt $lines.Count; $i++) {
    # Skip the old empty line to avoid doubling
    if ($i -eq $insertIdx -and $lines[$i].Trim() -eq '') {
        continue
    }
    $result.Add($lines[$i])
}

[System.IO.File]::WriteAllLines($FilePath, $result)
Write-Host "Inserted after '$TargetString' in $FilePath"
