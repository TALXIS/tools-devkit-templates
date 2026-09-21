$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append columns to the resolved
# tab or tab footer, creating the columns container when missing.

& txc workspace component apply-scaffold `
    --component-type 'FormColumn' `
    --file 'column=.template.temp/column.xml' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'tab-id=tabexampleid' `
    --param 'tab-index=tabnumberexample' `
    --param 'set-to-tab-footer=settotabfooterchoice'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
