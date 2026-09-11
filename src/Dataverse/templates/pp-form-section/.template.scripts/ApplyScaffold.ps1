$ErrorActionPreference = 'Stop'

# Single interim post-action: all XML mutations run in-process inside the TALXIS CLI
# (txc workspace component apply-scaffold), backed by the platform metadata library.
# The library also takes over SetVariables.ps1: it generates the section id when
# none was given and normalizes the name attribute from the display name.

& txc workspace component apply-scaffold `
    --component-type 'FormSection' `
    --solution-root '__solution-root-path__' `
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
