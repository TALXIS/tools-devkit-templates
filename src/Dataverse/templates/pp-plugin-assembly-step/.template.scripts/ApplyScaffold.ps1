$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to fill the step payload with
# filtering attributes, public key token and plugin type id from the assembly
# .dll.data.xml, copy it to SdkMessageProcessingSteps/{id}.xml, and register
# the type-92 RootComponent. Forwards filtering attributes only when present.

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'PluginAssemblyStep',
    '--file', 'step=.template.temp/__step-id__.xml',
    '--param', 'step-id=__step-id__',
    '--param', 'assembly-name=__assembly-name__',
    '--param', 'plugin-class-name=__plugin-class-name__'
)
if ('__filtering-attributes__' -ne '') { $argsList += @('--param', 'filtering-attributes=__filtering-attributes__') }

& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.temp -Recurse -Force
Remove-Item .template.scripts -Recurse -Force
