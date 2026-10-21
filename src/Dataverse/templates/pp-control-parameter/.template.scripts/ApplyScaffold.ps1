$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to remove unused placeholder nodes
# from the rendered parameters fragment and append parameters to the targeted control.

& txc workspace component apply-scaffold `
    --component-type 'ControlParameter' `
    --file 'parameters=.template.temp/parameters.xml' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'tab-id=tabexampleid' `
    --param 'tab-index=tabnumberexample' `
    --param 'column-index=columnnumberexample' `
    --param 'section-id=sectionidexample' `
    --param 'section-index=sectionnumberexample' `
    --param 'row-index=rownumberexample' `
    --param 'set-to-tab-footer=settotabfooterchoice'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
