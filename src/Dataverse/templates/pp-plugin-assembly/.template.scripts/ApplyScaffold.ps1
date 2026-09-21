$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to resolve the built plugin DLL
# using MSBuild property evaluation and inspect IPlugin types without loading
# the assembly for execution. Writes PluginAssemblies/<name>.dll.data.xml
# and registers the type-91 RootComponent.

& txc workspace component apply-scaffold `
    --component-type 'PluginAssembly' `
    --param 'plugin-project-root=__plugin-project-root__' `
    --param 'assembly-id=__assembly-id__'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
