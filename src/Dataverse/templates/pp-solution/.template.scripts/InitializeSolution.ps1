# Initialize a Dataverse solution project
pac solution init --publisher-name examplepublisher --publisher-prefix examplepublisherprefix --outputDirectory Solutions.Example
cd Solutions.Example

# Rename the src folder (produced by PAC CLI to remove the double src folder)
# and remove the unnecessary .gitignore file (we already have one in the root)
Rename-Item -Path .\src -NewName Declarations && Remove-Item .gitignore -Force

# Rename the solution component folder in .cdsproj and add the missing project type ID to make dotnet accept the custom project type
$csproj = Get-ChildItem -Path . -Filter *.cdsproj | Select-Object -First 1; [xml]$xml = Get-Content $csproj.FullName -Raw; $propertyGroup = $xml.Project.PropertyGroup | Where-Object { $_.SolutionRootPath } | Select-Object -First 1; $propertyGroup.SolutionRootPath = 'Declarations'; $newElement = $xml.CreateElement('DefaultProjectTypeGuid', $xml.Project.NamespaceURI); $newElement.InnerText = 'FAE04EC0-301F-11D3-BF4B-00C04F79EFBC'; $propertyGroup.AppendChild($newElement) > $null; $xml.Save($csproj.FullName)

# Switch solution ty to both
# sanitize UniqueName element value to remove characters other than letters and numbers
# by finding the first Solution.xml in subfolders, then reading the xml, them readint element value of ImportExportXml/SolutionManifest/UniqueName and then updating it with the sanitized value
$solutionXml = Get-ChildItem -Path . -Filter Solution.xml -Recurse | Select-Object -First 1; [xml]$xml = Get-Content $solutionXml.FullName -Raw; $uniqueName = $xml.ImportExportXml.SolutionManifest.UniqueName; $sanitized = [regex]::Replace($uniqueName, '[^a-zA-Z0-9]', ''); $xml.ImportExportXml.SolutionManifest.UniqueName = $sanitized; $xml.ImportExportXml.SolutionManifest.Managed = 2; $xml.Save($solutionXml.FullName)

cd ..