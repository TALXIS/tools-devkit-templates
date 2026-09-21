$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to append an AppModuleComponent
# to AppModule.xml: entities (type 1) use schema names and other types use braced ids.
# A missing AppModule.xml produces a warning. Optional parameters are passed
# only when populated.

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'AppModuleComponent',
    '--file', 'app-module=__solution-root-path__/AppModules/appexamplename/AppModule.xml',
    '--param', 'component-type-id=entitytypeexample'
)
if ('entityexamplename' -ne '') { $argsList += @('--param', 'entity=entityexamplename') }
if ('appmodelcomponentidexample' -ne '') { $argsList += @('--param', 'component-id=appmodelcomponentidexample') }

& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
