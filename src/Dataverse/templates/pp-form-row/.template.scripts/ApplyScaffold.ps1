$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append rows to the resolved
# section or tab footer, creating the rows container when missing.

& txc workspace component apply-scaffold `
    --component-type 'FormRow' `
    --file 'row=.template.temp/row.xml' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'tab-id=tabexampleid' `
    --param 'tab-index=tabnumberexample' `
    --param 'column-index=columnnumberexample' `
    --param 'section-id=sectionidexample' `
    --param 'section-index=sectionnumberexample' `
    --param 'set-to-tab-footer=settotabfooterchoice'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
