$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to fill type code, names and ids
# in data.xml, copy the source file to WebResources/, and register the type-61 RootComponent.

& txc workspace component apply-scaffold `
    --component-type 'WebResource' `
    --file 'source=webresourcefilepathexample' `
    --file 'data=__solution-root-path__/WebResources/examplepublisher_fileexamplename.data.xml' `
    --param 'publisher-prefix=examplepublisher'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# For a .js web resource, adds a ProjectReference to the project owning the source file.
$sourcePath = "webresourcefilepathexample"
if ([System.IO.Path]::GetExtension($sourcePath).ToLower() -eq '.js') {
    $path = (Resolve-Path $sourcePath).Path
    $root = Split-Path (Split-Path (Split-Path $path -Parent) -Parent) -Parent
    $csproj = Get-ChildItem -Path $root -Filter *.csproj -File | Select-Object -First 1
    $relative = [System.IO.Path]::GetRelativePath((Get-Location).Path, $csproj.FullName)
    dotnet add reference $relative
}

Remove-Item .template.scripts -Recurse -Force
