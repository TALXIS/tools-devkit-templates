$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to register the flow as a
# Solution.xml root component (type 29, by id). Passes the workflow id directly.

& txc workspace component apply-scaffold `
    --component-type 'Flow' `
    --param 'workflow-id=__flow-workflow-id__'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
