$solutionRootPath = "SolutionDeclarationsRoot"

if ($solutionRootPath -ne ".") { return }

$projectRoot = (Get-Location).Path

$stranded = Join-Path $projectRoot "SolutionDeclarationsRoot"
$strandedResolved = (Resolve-Path -LiteralPath $stranded -ErrorAction SilentlyContinue)?.Path
# Skip if the stranded path resolves to the project root itself (SolutionRootPath was '.')
if ($strandedResolved -and $strandedResolved -ne $projectRoot -and (Test-Path -LiteralPath $stranded)) {
    Get-ChildItem -LiteralPath $stranded -Force | ForEach-Object {
        Move-Item -LiteralPath $_.FullName -Destination $projectRoot -Force
    }
    Remove-Item -LiteralPath $stranded -Recurse -Force
}

Get-ChildItem -LiteralPath $projectRoot -Filter *.csproj -File | ForEach-Object {
    $lines = Get-Content -LiteralPath $_.FullName
    $filtered = $lines | Where-Object { $_ -notmatch '^\s*<SolutionRootPath>\.</SolutionRootPath>\s*$' }
    Set-Content -LiteralPath $_.FullName -Value $filtered
}
