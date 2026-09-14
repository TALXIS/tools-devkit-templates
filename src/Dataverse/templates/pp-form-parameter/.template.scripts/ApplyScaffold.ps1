$ErrorActionPreference = 'Stop'

# Single interim post-action: all XML mutations run in-process inside the TALXIS CLI
# (txc workspace component apply-scaffold), backed by the platform metadata library.

& txc workspace component apply-scaffold `
    --component-type 'FormParameter' `
    --solution-root '__solution-root-path__' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'parameter-name=nameexample' `
    --param 'parameter-type=typeexample'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
