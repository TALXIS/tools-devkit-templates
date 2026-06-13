$Placeholder = "__publisher-prefix-default-value__"

$prefix = ./.template.scripts/Get-CustomizationPrefix.ps1

& (Join-Path $PSScriptRoot 'ReplacePlaceholder.ps1') `
    -Path . `
    -Placeholder $Placeholder `
    -Replacement $prefix
