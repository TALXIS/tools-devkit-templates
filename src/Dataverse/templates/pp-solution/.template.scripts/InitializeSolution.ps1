# Initialize a Dataverse solution project using PAC CLI
pac solution init --publisher-name "examplepublisher" --publisher-prefix "examplepublisherprefix" --outputDirectory "SolutionLogicalNameExample"
cd "SolutionLogicalNameExample"

# Rename the src folder (produced by PAC CLI to remove the double src folder)
# and remove the unnecessary .gitignore file (we already have one in the repository root)
Rename-Item -Path .\src -NewName Declarations && Remove-Item .gitignore -Force

# Find the .cdsproj file and read it as XML
$csproj = Get-ChildItem -Path . -Filter *.cdsproj | Select-Object -First 1
[xml]$xml = Get-Content $csproj.FullName -Raw

# Rename the solution component folder in .cdsproj and 
$propertyGroup = $xml.Project.PropertyGroup | Where-Object { $_.SolutionRootPath } | Select-Object -First 1
$propertyGroup.SolutionRootPath = 'Declarations'

# Add the missing project type ID to make dotnet accept the custom project type
$newElement = $xml.CreateElement('DefaultProjectTypeGuid', $xml.Project.NamespaceURI)
$newElement.InnerText = 'FAE04EC0-301F-11D3-BF4B-00C04F79EFBC'
$propertyGroup.AppendChild($newElement) > $null
$newElement2 = $xml.CreateElement('ProjectTypeGuids', $xml.Project.NamespaceURI)
$newElement2.InnerText = 'FAE04EC0-301F-11D3-BF4B-00C04F79EFBC'
$propertyGroup.AppendChild($newElement2) > $null

# Override the default Publish target to prevent errors when running publish on .sln file
$targetElement = $xml.CreateElement('Target', $xml.Project.NamespaceURI)
$targetElement.SetAttribute('Name', 'Publish')
$comment = $xml.CreateComment(' Override the default Publish target to prevent errors when running publish on .sln file ')
$xml.Project.AppendChild($comment) > $null
$xml.Project.AppendChild($targetElement) > $null

# Save the updated XML back to the .cdsproj file
$xml.Save($csproj.FullName)

# Find the Solution.xml file and read it as XML
$solutionXml = Get-ChildItem -Path . -Filter Solution.xml -Recurse | Select-Object -First 1
[xml]$xml = Get-Content $solutionXml.FullName -Raw

# Find the UniqueName element and sanitize it
$uniqueName = $xml.ImportExportXml.SolutionManifest.UniqueName
$sanitized = [regex]::Replace($uniqueName, '[^a-zA-Z0-9]', '')
$xml.ImportExportXml.SolutionManifest.UniqueName = $sanitized

# Switch solution type to both to support packing managed solutions using SolutionPackager
$xml.ImportExportXml.SolutionManifest.Managed = 2

# Save the updated XML back to the file
$xml.Save($solutionXml.FullName)

cd ..

# Move the solution files from the temp folder to the root
Move-Item -Path "SolutionLogicalNameExample\*" -Destination . -Force
Remove-Item -Path "SolutionLogicalNameExample" -Force

# The new project is automatically added to the Visual Studio solution by the templating engine
# This would be an alternative: dotnet sln ../../ add SolutionLogicalNameExample.cdsproj"
