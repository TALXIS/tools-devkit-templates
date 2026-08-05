$ErrorActionPreference = 'Stop'

$json = 'jsonarraystringwhithPrivilegeTypeandandLevel'

$fixedJson = [regex]::Replace($json, '(\w+):\s*(\w+)', '"$1": "$2"')
$permissions = @(ConvertFrom-Json -InputObject $fixedJson)

$scriptsDir = if ((Split-Path -Path (Get-Location) -Leaf) -eq '.template.scripts') { (Get-Location).Path } else { Join-Path (Get-Location).Path '.template.scripts' }
$null = New-Item -ItemType Directory -Path $scriptsDir -Force

$lines = @(
    foreach ($permission in $permissions) {
        "<RolePrivilege name=`"prv$($permission.PrivilegeType)entityexamplename`" level=`"$($permission.Level)`" />"
    }
)

Set-Content -Path (Join-Path $scriptsDir 'privileges.xml') -Value $lines
