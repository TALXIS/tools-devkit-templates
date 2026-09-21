$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append rendered HideCustomAction
# entries to CustomActions in the entity's RibbonDiff.xml. An empty payload makes no changes.

& txc workspace component apply-scaffold `
    --component-type 'RibbonButtonHide' `
    --file 'ribbon=__solution-root-path__/Entities/exampleentityname/RibbonDiff.xml' `
    --file 'hide=.template.temp/customactionstohide.xml'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.temp -Recurse -Force
Remove-Item .template.scripts -Recurse -Force
