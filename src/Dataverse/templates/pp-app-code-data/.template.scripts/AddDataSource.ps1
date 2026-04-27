$filePath = "power.config.json"

$lowercasename = "entityexamplelogicalname"
$noPrefixName = $lowercasename.Split('_')[1]  + "s"

if (-not (Test-Path $filePath)) {
    Write-Error "File not found: $filePath"
    exit 1
}

$json = Get-Content $filePath -Raw | ConvertFrom-Json

# Ensure default.cds exists inside databaseReferences
if (-not $json.databaseReferences.'default.cds') {
    $json.databaseReferences | Add-Member -NotePropertyName 'default.cds' -NotePropertyValue ([PSCustomObject]@{
        dataSources = [PSCustomObject]@{}
        environmentVariableName = ''
    })
    Write-Host "Added default.cds to databaseReferences."
}

# Add datasource if not already present
$ds = $json.databaseReferences.'default.cds'.dataSources
if (-not $ds.$noPrefixName) {
    $ds | Add-Member -NotePropertyName $noPrefixName -NotePropertyValue ([PSCustomObject]@{
        entitySetName = $lowercasename + "s"
        logicalName   = $lowercasename
    })
    Write-Host "Added datasource '$noPrefixName'."
} else {
    Write-Host "Datasource '$noPrefixName' already exists, skipping."
}

$json | ConvertTo-Json -Depth 10 | Set-Content $filePath -NoNewline
Write-Host "Updated $filePath"
