$ErrorActionPreference = 'Stop'

$solutionName = @'
__solution-name__
'@

if ([string]::IsNullOrWhiteSpace($solutionName)) {
    Write-Host "SolutionName was not provided; skipping solution ProjectReference wiring."
    exit 0
}

$projectName = Split-Path -Leaf (Get-Location).Path
$projectPath = Join-Path (Get-Location).Path "$projectName.csproj"
$solutionProjectPath = Join-Path (Split-Path -Parent (Get-Location).Path) "$solutionName/$solutionName.csproj"

if (-not (Test-Path -LiteralPath $projectPath)) {
    Write-Error "Could not find scaffolded GenPage project: $projectPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $solutionProjectPath)) {
    Write-Host "Solution project '$solutionProjectPath' was not found; skipping solution ProjectReference wiring."
    exit 0
}

dotnet add $solutionProjectPath reference $projectPath
