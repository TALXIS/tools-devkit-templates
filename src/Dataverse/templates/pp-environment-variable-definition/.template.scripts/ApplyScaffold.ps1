$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to remove empty defaultvalue
# and description elements, write the definition and register its RootComponent
# (type 380, by schema name). Registration is skipped with a warning
# when Solution.xml is absent.

& txc workspace component apply-scaffold `
    --component-type 'EnvironmentVariableDefinition' `
    --file 'definition=__solution-root-path__/environmentvariabledefinitions/__schema-name__/environmentvariabledefinition.xml' `
    --param 'schema-name=__schema-name__'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
