$lowercasename = "entityexamplelogicalname"
$capitalizedname = $lowercasename.Substring(0,1).ToUpper() + $lowercasename.Substring(1)
$modelSolutionPath = (Resolve-Path "modelsolutionexamplepath").Path

$targetGenerated = Join-Path "src" "generated"
$targetIndexTs = Join-Path $targetGenerated "index.ts"

if (-not (Test-Path $targetIndexTs)) 
{
    New-Item -ItemType Directory -Path $targetGenerated -Force | Out-Null

    Copy-Item (Join-Path ".template.temp" "models") -Destination $targetGenerated -Recurse -Force
    Copy-Item (Join-Path ".template.temp" "index.ts") -Destination $targetGenerated -Force
}

& (Join-Path $PSScriptRoot 'ReplacePlaceholder.ps1') -FilePath (Join-Path "src" "generated" "services" "capitalizedentitylogicalnameexamplesService.ts") -Placeholder "lowercaseentitylogicalnameexample" -Replacement $lowercasename
& (Join-Path $PSScriptRoot 'ReplacePlaceholder.ps1') -FilePath (Join-Path "src" "generated" "services" "capitalizedentitylogicalnameexamplesService.ts") -Placeholder "capitalizedentitylogicalnameexample" -Replacement $capitalizedname

$generateModelScript = Join-Path $PSScriptRoot "GenerateModel.csx"
$generatedModelsPath = Join-Path "src" "generated" "models"
Start-Process dotnet-script -ArgumentList "`"$generateModelScript`" -- `"$modelSolutionPath`" `"entityexamplelogicalname`" `"$generatedModelsPath`"" -NoNewWindow -Wait

$modelIndexString = "export * as "+ $capitalizedname + "sModel from './models/"+ $capitalizedname + "sModel';"
$serviceIndexString = "export * from './services/" + $capitalizedname + "sService';"

$generatedIndexTs = Join-Path "src" "generated" "index.ts"
& (Join-Path $PSScriptRoot 'InsertAfterTarget.ps1') -TargetString "// Models" -SettingString $modelIndexString -FilePath $generatedIndexTs
& (Join-Path $PSScriptRoot 'InsertAfterTarget.ps1') -TargetString "// Services" -SettingString $serviceIndexString -FilePath $generatedIndexTs

& (Join-Path $PSScriptRoot 'AddDataSource.ps1')

& (Join-Path $PSScriptRoot 'AddDataSourceInfo.ps1') -SolutionPath $modelSolutionPath -EntityLogicalName "entityexamplelogicalname" -FilePath (Join-Path ".power" "schemas" "appschemas" "dataSourcesInfo.ts")

$generateSchemaScript = Join-Path $PSScriptRoot "GenerateSchema.csx"
$dataverseSchemasPath = Join-Path ".power" "schemas" "dataverse"
Start-Process dotnet-script -ArgumentList "`"$generateSchemaScript`" -- `"$modelSolutionPath`" `"entityexamplelogicalname`" `"$dataverseSchemasPath`"" -NoNewWindow -Wait
