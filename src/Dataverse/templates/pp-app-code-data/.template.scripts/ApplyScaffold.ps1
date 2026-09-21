$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to initialize src/generated,
# finalize the service file name and content, generate the TypeScript model and
# Dataverse JSON schema, and register the data source in index.ts,
# power.config.json and dataSourcesInfo.ts.

& txc workspace component apply-scaffold `
    --component-type 'AppCodeData' `
    --file 'service=src/generated/services/capitalizedentitylogicalnameexamplesService.ts' `
    --file 'index-template=.template.temp/index.ts' `
    --file 'common-models=.template.temp/models/CommonModels.ts' `
    --param 'entity=entityexamplelogicalname' `
    --param 'model-solution-root=modelsolutionexamplepath/__solution-root-path__'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
