$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to locate the command definition
# and its JavaScriptFunction in the entity's RibbonDiff.xml and append rendered
# parameters. Failed lookups report the available candidates.

& txc workspace component apply-scaffold `
    --component-type 'RibbonCommandParameter' `
    --file 'ribbon=__solution-root-path__/Entities/__entity-logical-name__/RibbonDiff.xml' `
    --file 'parameters=.template.temp/parameter.xml' `
    --param 'command-id=__publisher-prefix__.__entity-logical-name__.Command.__button-logical-name__' `
    --param 'function-name=__function-name__'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.temp -Recurse -Force
Remove-Item .template.scripts -Recurse -Force
