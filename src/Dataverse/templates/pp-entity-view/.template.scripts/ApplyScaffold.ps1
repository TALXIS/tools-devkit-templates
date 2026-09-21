$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to normalize GUID braces
# in SavedQuery file names and savedqueryid values.

& txc workspace component apply-scaffold `
    --component-type 'EntityView' `
    --param 'entity=exampleexistingentity'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
