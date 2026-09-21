$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append cells to the resolved row,
# using the dialog fragment for dialog forms.

& txc workspace component apply-scaffold `
    --component-type 'FormCell' `
    --file 'cell=.template.temp/cell.xml' `
    --file 'dialog-cell=.template.temp/dialogcell.xml' `
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
