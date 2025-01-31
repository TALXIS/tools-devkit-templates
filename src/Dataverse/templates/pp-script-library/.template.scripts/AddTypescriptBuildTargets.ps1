# Find the .cdsproj file and read it as XML
$csproj = Get-ChildItem -Path . -Filter *.cdsproj | Select-Object -First 1
[xml]$xml = Get-Content $csproj.FullName -Raw

$rootComponents = $xml.SelectSingleNode("//Project")

$npmInstallComponent = $xml.CreateElement("Target",$xml.Project.NamespaceURI)
$npmInstallComponent.SetAttribute("Name", 'npmInstall')
$npmInstallComponent.SetAttribute("BeforeTargets", 'BeforeBuild')
$npmInstallComponent.SetAttribute("Condition", "Exists(`'`$(ProjectDir)TS\package.json`') AND !Exists(`'`$(ProjectDir)TS\node_modules`')")

$execComponent = $xml.CreateElement("Exec", $xml.Project.NamespaceURI)
$execComponent.SetAttribute("Command", "npm install")
$execComponent.SetAttribute("WorkingDirectory", "`$(ProjectDir)TS")
$execComponent.SetAttribute("ConsoleToMsBuild", "true")

$npmInstallComponent.AppendChild($execComponent)

$npmBuildComponent = $xml.CreateElement("Target", $xml.Project.NamespaceURI)
$npmBuildComponent.SetAttribute("Name", 'buildTypescript')
$npmBuildComponent.SetAttribute("BeforeTargets", 'BeforeBuild')
$npmBuildComponent.SetAttribute("Condition", "Exists(`'`$(ProjectDir)TS\package.json`')")

$execComponent = $xml.CreateElement("Exec",$xml.Project.NamespaceURI)
$execComponent.SetAttribute("Command", "npm run build")
$execComponent.SetAttribute("WorkingDirectory", "`$(ProjectDir)TS")
$execComponent.SetAttribute("ConsoleToMsBuild", "true")

$npmBuildComponent.AppendChild($execComponent)

$xml.Project.AppendChild($npmInstallComponent)
$xml.Project.AppendChild($npmBuildComponent)

# Save the updated XML back to the .cdsproj file
$xml.Save($csproj.FullName)