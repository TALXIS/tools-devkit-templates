$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to write the value payload.
# A single-quoted here-string preserves the raw value, including quotes,
# backslashes and JSON fragments.

$rawValue = @'
__envvar-raw-value__
'@
$rawValue = $rawValue -replace "`r?`n\z", ""

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'EnvironmentVariableValue',
    '--file', 'values=__solution-root-path__/environmentvariabledefinitions/__definition-logical-name__/environmentvariablevalues.json',
    '--param', 'value-id=__envvar-value-id__',
    '--param', "value=$rawValue"
)
& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
