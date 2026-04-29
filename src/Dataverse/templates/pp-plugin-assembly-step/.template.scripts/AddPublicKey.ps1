$xmlPath = ".template.temp/__step-id__.xml" 
$assemblyName = "__assembly-name__"

# Search for the assembly data XML — supports both build-generated (flat) and
# pp-plugin-assembly (subfolder with GUID) directory layouts.
$assemblyXml = Get-ChildItem -Path "SolutionDeclarationsRoot/PluginAssemblies" -Filter "${assemblyName}.dll.data.xml" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($null -eq $assemblyXml) {
    Write-Error "Plugin assembly XML not found for '${assemblyName}' under SolutionDeclarationsRoot/PluginAssemblies/. Ensure the solution has been built or pp-plugin-assembly has been run."
    exit 1
}
if (-not (Test-Path $xmlPath)) {
    Write-Error "Step XML not found at: $xmlPath"
    exit 1
}

$xmlPluginPath = $assemblyXml.FullName
[xml]$xml = Get-Content $xmlPluginPath

$fullName = $xml.PluginAssembly.FullName
if ($fullName -match "PublicKeyToken=([a-zA-Z0-9]+)") {
    $publicKeyToken = $matches[1]
}
else {
    throw "PublicKeyToken not found in plugin file"
}

$content = Get-Content $xmlPath -Raw
if ($content -match 'PublicKeyToken=__public-key-token__') {
    $content = $content -replace '__public-key-token__', $publicKeyToken
    $content | Set-Content $xmlPath -Force
}

