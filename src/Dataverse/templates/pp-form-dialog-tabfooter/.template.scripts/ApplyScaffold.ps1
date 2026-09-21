$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append an empty tabfooter
# element to the resolved tab of a dialog form.

& txc workspace component apply-scaffold `
    --component-type 'FormDialogTabFooter' `
    --param 'form-id=formguididexample' `
    --param 'tab-id=tabexampleid' `
    --param 'tab-index=tabnumberexample' `
    --param 'tab-footer-id=tabfooterexampleid'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
