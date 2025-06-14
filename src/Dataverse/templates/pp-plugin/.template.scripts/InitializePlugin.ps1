# --- Input parameters ---
$signingKey = "signingkeyfilepathexample"
$outputDir = "../SolutionLogicalNameExample"
$author = "examplepublisher"
$company = "exampleсompany"

# --- 1. Initialize the plugin project ---
pac plugin init --signing-key-file-path $signingKey --outputDirectory $outputDir --author $author
cd $outputDir

# --- 2. Remove the auto-generated source file ---
Remove-Item .\Plugin1.cs -ErrorAction SilentlyContinue

# --- 3. Find the .csproj file ---
$csprojFile = Get-ChildItem -Path . -Filter *.csproj | Select-Object -First 1
if (-not $csprojFile) {
    exit 1
}

# --- 4. Generate AssemblyName by removing dots from the project name ---
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($csprojFile.Name)
$newAssemblyName = $projectName -replace '\.', ''
$ProjectPath = $csprojFile.FullName

# --- 5. Load .csproj as XML ---
[xml]$csproj = Get-Content $ProjectPath -Raw
$namespaceUri = $csproj.DocumentElement.NamespaceURI

# --- 6. Find or create a PropertyGroup ---
$propertyGroup = $csproj.Project.PropertyGroup | Where-Object { $_.AssemblyName -or $_.TargetFramework }
if (-not $propertyGroup) {
    $propertyGroup = $csproj.CreateElement("PropertyGroup", $namespaceUri)
    $csproj.Project.AppendChild($propertyGroup) | Out-Null
}

# --- 7. Remove existing AssemblyName and PackageId ---
$csproj.Project.PropertyGroup.AssemblyName | ForEach-Object {
    $_.ParentNode.RemoveChild($_) | Out-Null
}
$csproj.Project.PropertyGroup.PackageId | ForEach-Object {
    $_.ParentNode.RemoveChild($_) | Out-Null
}
$csproj.Project.PropertyGroup.Company | ForEach-Object {
    $_.ParentNode.RemoveChild($_) | Out-Null
}

# --- 8. Add new AssemblyName and PackageId ---
$assemblyNameElement = $csproj.CreateElement("AssemblyName", $namespaceUri)
$assemblyNameElement.InnerText = $newAssemblyName
$propertyGroup.AppendChild($assemblyNameElement) | Out-Null

# --- 9. Add new PackageId ---
$packageIdElement = $csproj.CreateElement("PackageId", $namespaceUri)
$packageIdElement.InnerText = $newAssemblyName
$propertyGroup.AppendChild($packageIdElement) | Out-Null

# --- 10. Add new Company ---
$companyElement = $csproj.CreateElement("Company", $namespaceUri)
$companyElement.InnerText = $company
$propertyGroup.AppendChild($companyElement) | Out-Null

# --- 11. Save changes back to the .csproj file ---
$csproj.Save($ProjectPath)