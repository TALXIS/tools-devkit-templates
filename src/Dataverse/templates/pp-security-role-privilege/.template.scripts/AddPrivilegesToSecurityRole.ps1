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
    $newName = $imported.GetAttribute('name')

    # Skip if privilege already exists (idempotency)
    $existing = $rolePrivilegesNode.SelectSingleNode("RolePrivilege[@name='$newName']")
    if ($existing) {
        # Update level if different
        $existing.SetAttribute('level', $imported.GetAttribute('level'))
        continue
    }

    # Insert in alphabetical order by name
    $insertBefore = $null
    foreach ($child in $rolePrivilegesNode.SelectNodes('RolePrivilege')) {
        if ([string]::Compare($child.GetAttribute('name'), $newName, [StringComparison]::OrdinalIgnoreCase) -gt 0) {
            $insertBefore = $child
            break
        }
    }

    if ($insertBefore) {
        $rolePrivilegesNode.InsertBefore($imported, $insertBefore) | Out-Null
    } else {
        $rolePrivilegesNode.AppendChild($imported) | Out-Null
    }
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()

