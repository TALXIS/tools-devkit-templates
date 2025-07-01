# Find the .cdsproj file and read it as XML
$csproj = Get-ChildItem -Path . -Filter *.cdsproj | Select-Object -First 1
[xml]$xml = Get-Content $csproj.FullName -Raw


$solutionPackageMapFilePathComponent = $xml.CreateElement("SolutionPackageMapFilePath",  $xml.Project.NamespaceURI)
$solutionPackageMapFilePathComponent.InnerText = "libraryprojectrootpathexamplemap.xml"

$xml.Project.PropertyGroup.AppendChild($solutionPackageMapFilePathComponent)

# Save the updated XML back to the .cdsproj file
$xml.Save($csproj.FullName)