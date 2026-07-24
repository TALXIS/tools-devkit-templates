$ErrorActionPreference = 'Stop'

$json = 'jsonarraystringwhithrolesids'

$guids = @(
    $json.Trim('[', ']').Split(',', [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Trim() }
)

$scriptsDir = if ((Split-Path -Path (Get-Location) -Leaf) -eq '.template.scripts') { (Get-Location).Path } else { Join-Path (Get-Location).Path '.template.scripts' }
$null = New-Item -ItemType Directory -Path $scriptsDir -Force

$lines = @(
    foreach ($permission in $guids) {
        "<Role id=`"{$($permission.Trim('{', '}'))}`" />"
    }
)

Set-Content -Path (Join-Path $scriptsDir 'appaccess.xml') -Value $lines
