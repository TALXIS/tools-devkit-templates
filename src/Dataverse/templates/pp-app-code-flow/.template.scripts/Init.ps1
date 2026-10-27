$flowSolutionPath = (Resolve-Path "flowsolutionexamplepath").Path

$targetGenerated = Join-Path "src" "generated"
$targetIndexTs = Join-Path $targetGenerated "index.ts"

# Same bootstrap as pp-app-code-data, so later data sources still find CommonModels
if (-not (Test-Path $targetIndexTs))
{
    New-Item -ItemType Directory -Path $targetGenerated -Force | Out-Null

    Copy-Item (Join-Path ".template.temp" "models") -Destination $targetGenerated -Recurse -Force
    Copy-Item (Join-Path ".template.temp" "index.ts") -Destination $targetGenerated -Force
}

$generateFlowScript = Join-Path $PSScriptRoot "GenerateFlow.cs"
$proc = Start-Process dotnet -ArgumentList "run --file `"$generateFlowScript`" -- `"$flowSolutionPath`" `"flowexamplename`" `"$((Get-Location).Path)`"" -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) { Write-Error "GenerateFlow.cs failed (exit code $($proc.ExitCode))"; exit 1 }
