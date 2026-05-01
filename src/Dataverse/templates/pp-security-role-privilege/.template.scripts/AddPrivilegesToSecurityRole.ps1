$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot/Roles/securityrolenameexample.xml').Path
$privilegesPath = (Resolve-Path '.template.scripts/privileges.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$rolePrivilegesNode = $entityXml.SelectSingleNode('//Role/RolePrivileges')
if (-not $rolePrivilegesNode) {
    Write-Error "Could not find Role/RolePrivileges node in the XML file."
    exit 1
}

$privilegesRaw = Get-Content -Path $privilegesPath -Raw
$wrapped = "<RolePrivileges>$privilegesRaw</RolePrivileges>"
[xml]$newPrivilegesXml = $wrapped

foreach ($privilege in $newPrivilegesXml.RolePrivileges.ChildNodes) {
    $imported = $entityXml.ImportNode($privilege, $true)
    $rolePrivilegesNode.AppendChild($imported) | Out-Null
}

# Sort all RolePrivilege elements alphabetically by name attribute
$allPrivileges = @($rolePrivilegesNode.SelectNodes('RolePrivilege'))
$sorted = $allPrivileges | Sort-Object { $_.GetAttribute('name') }

# Remove all existing privileges and re-add in sorted order
$rolePrivilegesNode.RemoveAll()
foreach ($priv in $sorted) {
    $rolePrivilegesNode.AppendChild($priv) | Out-Null
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()

