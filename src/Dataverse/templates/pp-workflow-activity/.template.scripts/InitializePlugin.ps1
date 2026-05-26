# --- Input parameters (templated) ---
$signingKey = "signingkeyfilepathexample"
$outputDir = "../SolutionLogicalNameExample"
$author = "examplepublisher"
$company = "exampleсompany"

# --- Resolve paths ---
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedOutputDir = Resolve-Path -Path $outputDir -ErrorAction SilentlyContinue
if (-not $resolvedOutputDir) {
    $resolvedOutputDir = Join-Path (Get-Location) $outputDir
}
$resolvedOutputDir = $resolvedOutputDir.ToString()
$useSigningKey = -not [string]::IsNullOrWhiteSpace($signingKey) -and $signingKey -ne "signingkeyfilepathexample"

# --- 1. Initialize project from PAC (plugin scaffold as base) ---
$pacArgs = @("plugin", "init", "--outputDirectory", $resolvedOutputDir, "--author", $author)
if ($useSigningKey) {
    $pacArgs += @("--signing-key-file-path", $signingKey)
} else {
    # Explicitly skip signing so PAC CLI does not auto-generate a key
    $pacArgs += @("--skip-signing")
}
pac @pacArgs
Set-Location $resolvedOutputDir

# --- 2. Drop plugin-specific generated files ---
@("Plugin1.cs", "PluginBase.cs") | ForEach-Object {
    Remove-Item $_ -ErrorAction SilentlyContinue
}

# --- 3. Add workflow activity base class from template temp folder ---
$workflowBaseSource = Join-Path (Split-Path $scriptRoot -Parent) ".template.temp/WorkflowActivityBase.cs"
if (Test-Path $workflowBaseSource) {
    Copy-Item $workflowBaseSource -Destination $resolvedOutputDir -Force
}

# --- 4. Locate the generated .csproj ---
$csprojFile = Get-ChildItem -Path . -Filter *.csproj | Select-Object -First 1
if (-not $csprojFile) {
    Write-Error "Could not find a .csproj file in the current directory."
    exit 1
}
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($csprojFile.Name)

# --- 5. Compose workflow-activities csproj (override existing) ---
$signAssemblyValue = if ($useSigningKey) { "true" } else { "false" }
$signingKeyLine = if ($useSigningKey) { "    <AssemblyOriginatorKeyFile>$signingKey</AssemblyOriginatorKeyFile>`n" } else { "" }
$csprojText = @"
<Project Sdk="TALXIS.DevKit.Build.Sdk/1.5.0">
  <PropertyGroup>
    <TargetFramework>net462</TargetFramework>
    <LangVersion>latest</LangVersion>
    <SignAssembly>$signAssemblyValue</SignAssembly>
$signingKeyLine    <AssemblyVersion>1.0.0.0</AssemblyVersion>
    <FileVersion>1.0.0.0</FileVersion>
    <ProjectType>WorkflowActivity</ProjectType>
    <AssemblyName>$projectName</AssemblyName>
  </PropertyGroup>
  <PropertyGroup>
    <Version>`$(FileVersion)</Version>
    <Authors>$author</Authors>
    <Company>$company</Company>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.CrmSdk.CoreAssemblies" Version="9.0.2.*" PrivateAssets="All" />
    <PackageReference Include="Microsoft.NETFramework.ReferenceAssemblies" Version="1.0.*" PrivateAssets="All" />
    <PackageReference Include="Microsoft.CrmSdk.Workflow" Version="*" />
    <PackageReference Include="Newtonsoft.Json" Version="13.0.*" />
  </ItemGroup>
  <ItemGroup>
    <Reference Include="System.Activities" />
  </ItemGroup>
</Project>
"@
Set-Content -Path $csprojFile.FullName -Value $csprojText -Encoding UTF8
