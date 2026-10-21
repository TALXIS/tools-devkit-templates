$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append the rendered section,
# generate its id when omitted, and normalize the name attribute from its display name.

& txc workspace component apply-scaffold `
    --component-type 'FormSection' `
    --file 'section=.template.temp/section.xml' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'tab-id=tabexampleid' `
    --param 'tab-index=tabnumberexample' `
    --param 'column-index=columnnumberexample' `
    --param 'set-to-tab-footer=settotabfooterchoice' `
    --param 'section-id=sectionidexample' `
    --param 'section-name=sectionnameexample'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
