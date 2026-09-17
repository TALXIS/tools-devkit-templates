$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to parse quoted or bare privilege
# JSON with the "type" key alias, map UI level names to role XSD values, and merge
# privileges idempotently. Level None omits the privilege. A here-string preserves
# quotes and braces in the specification.

$Privileges = @'
jsonarraystringwhithPrivilegeTypeandandLevel
'@
$Privileges = $Privileges -replace "`r?`n\z", ""

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'SecurityRolePrivilege',
    '--file', 'role=__solution-root-path__/Roles/securityrolenameexample.xml',
    '--param', 'entity=entityexamplename',
    '--param', "privileges=$Privileges"
)
& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
