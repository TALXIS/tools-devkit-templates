$name = Split-Path -Leaf (Get-Location)

& (Join-Path $PSScriptRoot 'ReplacePlaceholder.ps1') -Path (Get-Location).Path -Placeholder 'pdpackageexamplename' -Replacement $name
