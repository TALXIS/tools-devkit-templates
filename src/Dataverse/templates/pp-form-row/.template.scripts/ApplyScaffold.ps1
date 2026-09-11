$ErrorActionPreference = 'Stop'

# Single interim post-action: all XML mutations run in-process inside the TALXIS CLI
# (txc workspace component apply-scaffold), backed by the platform metadata library.

& txc workspace component apply-scaffold `
    --component-type 'FormRow' `
    --solution-root '__solution-root-path__' `
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
