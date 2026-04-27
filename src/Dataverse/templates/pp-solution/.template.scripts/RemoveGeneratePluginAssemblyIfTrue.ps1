$generatePluginAssembly = "generateexamplepluginassembly"

if ($generatePluginAssembly -ne "true") { return }

$projectRoot = (Get-Location).Path

Get-ChildItem -LiteralPath $projectRoot -Filter *.csproj -File | ForEach-Object {
    $lines = Get-Content -LiteralPath $_.FullName
    $filtered = $lines | Where-Object { $_ -notmatch '^\s*<GeneratePluginAssembly>.*</GeneratePluginAssembly>\s*$' }
    Set-Content -LiteralPath $_.FullName -Value $filtered
}
