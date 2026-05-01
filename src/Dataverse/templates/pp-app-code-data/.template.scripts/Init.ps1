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

$generateModelScript = Join-Path $PSScriptRoot "GenerateModel.cs"
$generatedModelsPath = Join-Path "src" "generated" "models"
$proc = Start-Process dotnet -ArgumentList "run --file `"$generateModelScript`" -- `"$modelSolutionPath`" `"entityexamplelogicalname`" `"$generatedModelsPath`"" -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) { Write-Error "GenerateModel.cs failed (exit code $($proc.ExitCode))"; exit 1 }

$modelIndexString = "export * as "+ $capitalizedname + "sModel from './models/"+ $capitalizedname + "sModel';"
$serviceIndexString = "export * from './services/" + $capitalizedname + "sService';"

$generatedIndexTs = Join-Path "src" "generated" "index.ts"
& (Join-Path $PSScriptRoot 'InsertAfterTarget.ps1') -TargetString "// Models" -SettingString $modelIndexString -FilePath $generatedIndexTs
& (Join-Path $PSScriptRoot 'InsertAfterTarget.ps1') -TargetString "// Services" -SettingString $serviceIndexString -FilePath $generatedIndexTs

& (Join-Path $PSScriptRoot 'AddDataSource.ps1')

& (Join-Path $PSScriptRoot 'AddDataSourceInfo.ps1') -SolutionPath $modelSolutionPath -EntityLogicalName "entityexamplelogicalname" -FilePath (Join-Path ".power" "schemas" "appschemas" "dataSourcesInfo.ts")

$generateSchemaScript = Join-Path $PSScriptRoot "GenerateSchema.cs"
$dataverseSchemasPath = Join-Path ".power" "schemas" "dataverse"
$proc = Start-Process dotnet -ArgumentList "run --file `"$generateSchemaScript`" -- `"$modelSolutionPath`" `"entityexamplelogicalname`" `"$dataverseSchemasPath`"" -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) { Write-Error "GenerateSchema.cs failed (exit code $($proc.ExitCode))"; exit 1 }
