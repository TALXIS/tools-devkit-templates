$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to parse bare, braced or quoted
# role GUIDs, reject non-GUIDs, and update AppModuleRoleMaps. The complete new node
# is built before the existing node is removed. A here-string preserves braces
# and quotes in the ids.

$RoleIds = @'
jsonarraystringwhithrolesids
'@
$RoleIds = $RoleIds -replace "`r?`n\z", ""

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'AppSecurityRole',
    '--file', 'app-module=__solution-root-path__/AppModules/appexamplename/AppModule.xml',
    '--param', "role-ids=$RoleIds"
)
& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
