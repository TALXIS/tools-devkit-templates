$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append rendered subgrid rows
# to the target form's first rows container.

& txc workspace component apply-scaffold `
    --component-type 'FormSubgrid' `
    --file 'row=.template.temp/subgrid.xml' `
    --param 'entity=__entity-logical-name__' `
    --param 'form-type=__form-type__' `
    --param 'form-id=__form-id__'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
