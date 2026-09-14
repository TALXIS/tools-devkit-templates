$ErrorActionPreference = 'Stop'

# Single interim post-action: all XML mutations run in-process inside the TALXIS CLI
# (txc workspace component apply-scaffold), backed by the platform metadata library.
# The library registers the role as a Solution.xml root component (type 20, by id).

& txc workspace component apply-scaffold `
    --component-type 'SecurityRole' `
    --solution-root '__solution-root-path__' `
    --param 'role-id=roleidexample'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
