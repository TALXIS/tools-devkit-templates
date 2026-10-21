$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to register the security role
# in Solution.xml as a root component (type 20, by id).

& txc workspace component apply-scaffold `
    --component-type 'SecurityRole' `
    --param 'role-id=roleidexample'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
