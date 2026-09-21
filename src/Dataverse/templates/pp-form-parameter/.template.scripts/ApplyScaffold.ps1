$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to register a querystringparameter
# in formparameters, creating the container when missing and leaving an existing
# parameter with the same name untouched.

& txc workspace component apply-scaffold `
    --component-type 'FormParameter' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'parameter-name=nameexample' `
    --param 'parameter-type=typeexample'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
