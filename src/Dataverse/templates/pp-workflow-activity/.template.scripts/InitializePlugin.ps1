# --- Input parameters ---
$signingKey = "signingkeyfilepathexample"
$outputDir = "../SolutionLogicalNameExample"

# --- 1. Enter the project directory ---
cd $outputDir

# --- 2. Find the .csproj file ---
$csprojFile = Get-ChildItem -Path . -Filter *.csproj | Select-Object -First 1
if (-not $csprojFile) {
    Write-Error "Could not find a .csproj file in the current directory."
    exit 1
}

# --- 3. Wire up assembly signing when a key was provided ---
# placeholder is split so the template engine does not substitute it here as well
$placeholder = "signingkeyfilepath" + "example"
$useSigningKey = -not [string]::IsNullOrWhiteSpace($signingKey) -and $signingKey -ne $placeholder
if ($useSigningKey) {
    # relative paths are searched from the project directory up through its parents,
    # because post actions run inside the output directory, not where dotnet new was invoked
    $snkSource = $null
    if ([System.IO.Path]::IsPathRooted($signingKey)) {
        if (Test-Path $signingKey) { $snkSource = $signingKey }
    } else {
        $dir = (Get-Location).Path
        while ($dir) {
            $candidate = Join-Path $dir $signingKey
            if (Test-Path $candidate) { $snkSource = $candidate; break }
            $dir = Split-Path $dir -Parent
        }
    }
    if (-not $snkSource) {
        Write-Error "Signing key file not found: '$signingKey'. Pass a path to an existing .snk file or omit --SigningKeyFilePath to skip signing."
        exit 1
    }
    $snkSource = (Resolve-Path $snkSource).Path
    $snkFileName = [System.IO.Path]::GetFileName($snkSource)
    $snkDestination = Join-Path (Get-Location) $snkFileName
    if ($snkSource -ne $snkDestination) { Copy-Item $snkSource -Destination $snkDestination -Force }
    Write-Host "Using provided SNK file: $snkSource"

    [xml]$csproj = Get-Content $csprojFile.FullName -Raw
    $namespaceUri = $csproj.DocumentElement.NamespaceURI
    $propertyGroup = $csproj.Project.PropertyGroup | Select-Object -First 1
    $propertyGroup.SignAssembly = "true"
    $keyElement = $csproj.CreateElement("AssemblyOriginatorKeyFile", $namespaceUri)
    $keyElement.InnerText = $snkFileName
    $propertyGroup.AppendChild($keyElement) | Out-Null
    $csproj.Save($csprojFile.FullName)
}
