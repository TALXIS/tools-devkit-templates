$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append the rendered tab,
# remove the scaffolded default tab on request, generate the tab id when omitted,
# and normalize the name attribute from its display name.

& txc workspace component apply-scaffold `
    --component-type 'FormTab' `
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
