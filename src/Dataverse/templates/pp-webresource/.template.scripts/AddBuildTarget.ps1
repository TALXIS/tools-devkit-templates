
$relativePath = "webresourcefilepathexample"

$path = (Resolve-Path $relativePath).Path
$root = (Split-Path $path -Parent)         
$root = (Split-Path $root -Parent)   
$root = (Split-Path $root -Parent)        
$csproj = Get-ChildItem -Path $root -Filter *.csproj -File | Select-Object -First 1

$base = (Get-Location).Path
$relative = [System.IO.Path]::GetRelativePath($base, $csproj.FullName)

dotnet add reference $relative