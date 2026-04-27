param(
    [Parameter(Mandatory)][string]$SolutionPath,
    [Parameter(Mandatory)][string]$EntityLogicalName,
    [Parameter(Mandatory)][string]$FilePath
)

# Parse Entity.xml to get EntitySetName and PrimaryKey
$entityXmlPath = Join-Path $SolutionPath "SolutionDeclarationsRoot" "Entities" $EntityLogicalName "Entity.xml"
if (-not (Test-Path $entityXmlPath)) {
    Write-Error "Entity.xml not found: $entityXmlPath"
    exit 1
}

[xml]$xml = Get-Content $entityXmlPath
$entity = $xml.Entity.EntityInfo.entity
$EntitySetName = $entity.EntitySetName

$PrimaryKey = $null
foreach ($attr in $entity.attributes.attribute) {
    if ($attr.Type -eq 'primarykey') {
        $PrimaryKey = $attr.LogicalName
        break
    }
}

if (-not $PrimaryKey) {
    Write-Error "Primary key not found in $entityXmlPath"
    exit 1
}

Write-Host "Parsed: EntitySetName='$EntitySetName', PrimaryKey='$PrimaryKey'"

# Ensure output directory exists
$dir = Split-Path $FilePath -Parent
if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$newEntry = @"
  "$EntitySetName": {
    "tableId": "",
    "version": "",
    "primaryKey": "$PrimaryKey",
    "dataSourceType": "Dataverse",
    "apis": {}
  }
"@

if (-not (Test-Path $FilePath)) {
    $content = @"
/*!
 * Copyright (C) Microsoft Corporation. All rights reserved.
 * This file is auto-generated. Do not modify it manually.
 * Changes to this file may be overwritten.
 */

export const dataSourcesInfo = {
$newEntry
};
"@
    [System.IO.File]::WriteAllText($FilePath, $content.Replace("`r`n", "`n") + "`n")
    Write-Host "Created $FilePath with '$EntitySetName'."
    return
}

# File exists — check if entry already present
$text = [System.IO.File]::ReadAllText($FilePath)

if ($text.Contains("`"$EntitySetName`"")) {
    Write-Host "'$EntitySetName' already exists in $FilePath, skipping."
    return
}

$lines = [System.IO.File]::ReadAllLines($FilePath)
$result = [System.Collections.Generic.List[string]]::new()

$closingIdx = -1
for ($i = $lines.Count - 1; $i -ge 0; $i--) {
    if ($lines[$i].TrimStart() -eq '};') {
        $closingIdx = $i
        break
    }
}

if ($closingIdx -eq -1) {
    Write-Error "Could not find closing '};' in $FilePath"
    exit 1
}

$lastEntryClose = -1
for ($i = $closingIdx - 1; $i -ge 0; $i--) {
    if ($lines[$i].TrimStart() -eq '}') {
        $lastEntryClose = $i
        break
    }
}

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($i -eq $lastEntryClose -and $lastEntryClose -ne -1) {
        $result.Add($lines[$i] + ',')
        foreach ($entryLine in $newEntry.Split("`n")) {
            $result.Add($entryLine)
        }
    }
    elseif ($i -eq $closingIdx -and $lastEntryClose -eq -1) {
        foreach ($entryLine in $newEntry.Split("`n")) {
            $result.Add($entryLine)
        }
        $result.Add($lines[$i])
    }
    else {
        $result.Add($lines[$i])
    }
}

[System.IO.File]::WriteAllLines($FilePath, $result)
Write-Host "Added '$EntitySetName' to $FilePath"
