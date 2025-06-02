$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot/Roles/securityrolenameexample.xml').Path
$privilegesPath = (Resolve-Path '.template.scripts/privileges.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$rolePrivilegesNode = $entityXml.SelectSingleNode('//Role/RolePrivileges')
if (-not $rolePrivilegesNode) {
    exit 1
}

$privilegesRaw = Get-Content -Path $privilegesPath -Raw
$wrapped = "<RolePrivileges>$privilegesRaw</RolePrivileges>"
[xml]$newPrivilegesXml = $wrapped

foreach ($privilege in $newPrivilegesXml.RolePrivileges.ChildNodes) {
    $imported = $entityXml.ImportNode($privilege, $true)
    $rolePrivilegesNode.AppendChild($imported) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()

