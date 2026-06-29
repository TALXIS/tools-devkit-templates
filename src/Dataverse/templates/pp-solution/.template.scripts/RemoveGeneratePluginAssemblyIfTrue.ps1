$generatePluginAssembly = "generateexamplepluginassembly"

if ($generatePluginAssembly -ne "true") { return }

$projectRoot = (Get-Location).Path

Get-ChildItem -LiteralPath $projectRoot -Filter *.csproj -File | ForEach-Object {
    $lines = Get-Content -LiteralPath $_.FullName
    $filtered = $lines | Where-Object { $_ -notmatch '^\s*<GeneratePluginAssembly>.*</GeneratePluginAssembly>\s*$' }
    $filtered = ($filtered -join "`n").Replace("`r`n", "`n").Replace("`r", "`n")
    [System.IO.File]::WriteAllText($_.FullName, $filtered + "`n", [System.Text.UTF8Encoding]::new($false))
}
