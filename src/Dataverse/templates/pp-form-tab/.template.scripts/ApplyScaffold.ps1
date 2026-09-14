$ErrorActionPreference = 'Stop'

# Single interim post-action: all XML mutations run in-process inside the TALXIS CLI
# (txc workspace component apply-scaffold), backed by the platform metadata library.
# The library takes over RemoveDefaultTab.ps1 and SetVariables.ps1 too: it removes
# the scaffolded default tab on request, generates the tab id when none was given
# and normalizes the name attribute from the display name.

& txc workspace component apply-scaffold `
    --component-type 'FormTab' `
    --solution-root '__solution-root-path__' `
    --file 'tab=.template.temp/tab.xml' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'tab-id=tabexampleid' `
    --param 'display-name=exampletabdisplayname' `
    --param 'remove-default-tab=removefefaulttabchoice'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
