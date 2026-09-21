$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to fill the rendered option set
# with the requested options and register it in Solution.xml (type 9, by schema name).
# The workspace writer constructs the option XML.

& txc workspace component apply-scaffold `
    --component-type 'OptionSet' `
    --param 'optionset-name=examplepublisherprefix_examplecustomentityattribute' `
    --param 'options=optinsforoptionsetexample'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
