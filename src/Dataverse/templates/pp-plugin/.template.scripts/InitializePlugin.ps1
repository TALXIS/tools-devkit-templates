# --- Input parameters ---
$signingKey = "signingkeyfilepathexample"
$outputDir = "../SolutionLogicalNameExample"
$author = "examplepublisher"
$company = "exampleсompany"

# --- 1. Initialize the plugin project ---
cd $outputDir

# --- 2. Remove the auto-generated source file ---
Remove-Item .\Plugin1.cs -ErrorAction SilentlyContinue

# --- 3. Find the .csproj file ---
$csprojFile = Get-ChildItem -Path . -Filter *.csproj | Select-Object -First 1
if (-not $csprojFile) {
    Write-Error "Could not find a .csproj file in the current directory."
    exit 1
}

# --- 4. Generate AssemblyName by removing dots from the project name ---
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($csprojFile.Name)
$newAssemblyName = $projectName -replace '\.', ''
$ProjectPath = $csprojFile.FullName

# --- 5. Update the Sdk in the .csproj text and remove unwanted elements ---
$csprojText = Get-Content $ProjectPath -Raw
$csprojText = $csprojText -replace '<Project Sdk="Microsoft\.NET\.Sdk">', '<Project Sdk="TALXIS.DevKit.Build.Sdk/1.5.1">'
$csprojText = $csprojText -replace '\s*<PackageReference Include="Microsoft\.PowerApps\.MSBuild\.Plugin"[^>]*/>\s*', ''
$csprojText = $csprojText -replace '\s*<Import[^>]*Project="\$\(PowerAppsTargetsPath\)\\Microsoft\.PowerApps\.VisualStudio\.Plugin\.targets"[^>]*/>\s*', ''
$csprojText = $csprojText -replace '\s*<Import[^>]*Project="\$\(PowerAppsTargetsPath\)\\Microsoft\.PowerApps\.VisualStudio\.Plugin\.props"[^>]*/>\s*', ''
$csprojText = $csprojText -replace '\s*<ProjectTypeGuids>[^<]*</ProjectTypeGuids>\s*', ''
$csprojText = $csprojText -replace '\s*<PowerAppsTargetsPath>[^<]*</PowerAppsTargetsPath>\s*', ''
Set-Content -Path $ProjectPath -Value $csprojText

# --- 6. Load .csproj as XML ---
[xml]$csproj = $csprojText
$namespaceUri = $csproj.DocumentElement.NamespaceURI

# --- 7. Find or create the first PropertyGroup ---
$firstPropertyGroup = $csproj.Project.PropertyGroup | Select-Object -First 1
if (-not $firstPropertyGroup) {
    $firstPropertyGroup = $csproj.CreateElement("PropertyGroup", $namespaceUri)
    $csproj.Project.PrependChild($firstPropertyGroup) | Out-Null
}

# --- 8. Find or create a PropertyGroup ---
$propertyGroup = $csproj.Project.PropertyGroup | Where-Object { $_.AssemblyName -or $_.TargetFramework }
if (-not $propertyGroup) {
    $propertyGroup = $csproj.CreateElement("PropertyGroup", $namespaceUri)
    $csproj.Project.AppendChild($propertyGroup) | Out-Null
}

# --- 10. Add new AssemblyName and PackageId ---
$assemblyNameElement = $csproj.CreateElement("AssemblyName", $namespaceUri)
$assemblyNameElement.InnerText = $newAssemblyName
$propertyGroup.AppendChild($assemblyNameElement) | Out-Null

# --- 11. Add new PackageId ---
$packageIdElement = $csproj.CreateElement("PackageId", $namespaceUri)
$packageIdElement.InnerText = $newAssemblyName
$propertyGroup.AppendChild($packageIdElement) | Out-Null

# --- 12. Add new Company ---
$companyElement = $csproj.CreateElement("Company", $namespaceUri)
$companyElement.InnerText = $company
$propertyGroup.AppendChild($companyElement) | Out-Null

# --- 13. Generate SNK file if it doesn't exist (cross-platform, no sn.exe needed) ---
$snkPath = $signingKey
if (-not (Test-Path $snkPath)) {
    Write-Host "Generating strong name key file: $signingKey"
    Add-Type -AssemblyName System.Security.Cryptography.Csp -ErrorAction SilentlyContinue
    $csharp = @"
using System;
using System.IO;
using System.Security.Cryptography;
public static class SnkGenerator {
    public static void Create(string path) {
        using (var rsa = new RSACryptoServiceProvider(2048)) {
            byte[] blob = rsa.ExportCspBlob(true);
            blob[4] = 0x00; blob[5] = 0x24; blob[6] = 0x00; blob[7] = 0x00;
            File.WriteAllBytes(path, blob);
        }
    }
}
"@
    Add-Type -TypeDefinition $csharp -Language CSharp -ErrorAction Stop
    $snkPath = "AssemblyOriginatorKeyFile.snk"
    [SnkGenerator]::Create("$snkPath")
    Write-Host "Generated SNK file at: $snkPath"
}


$assemblyNameElement = $csproj.CreateElement("AssemblyOriginatorKeyFile", $namespaceUri)
$assemblyNameElement.InnerText = $snkPath
$propertyGroup.AppendChild($assemblyNameElement) | Out-Null

# --- 14. Save changes back to the .csproj file ---
$csproj.Save($ProjectPath)

# --- 15. Copy the PluginBase.cs file to the project ---
if ("pluginbasetypeexample" -eq "TALXIS") {
    Copy-Item ".template.temp/PluginBase.cs" -Destination . -Force
}

