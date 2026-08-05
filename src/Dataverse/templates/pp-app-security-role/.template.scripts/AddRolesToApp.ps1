$appModuleXmlPath = (Resolve-Path '__solution-root-path__/AppModules/appexamplename/AppModule.xml').Path
$rolesPath = (Resolve-Path '.template.scripts/appaccess.xml').Path

[xml]$appModuleXml = Get-Content -Path $appModuleXmlPath -Raw

$rootNode = $appModuleXml.SelectSingleNode('//AppModule')
if (-not $rootNode) {
    Write-Error "AppModule root not found"
    exit 1
}

$roleMapsNode = $rootNode.SelectSingleNode('AppModuleRoleMaps')
if (-not $roleMapsNode) {
    $roleMapsNode = $rootNode.AppendChild($appModuleXml.CreateElement('AppModuleRoleMaps'))
}

$rolesRaw = Get-Content -Path $rolesPath -Raw
[xml]$rolesXml = "<AppModuleRoleMaps>$rolesRaw</AppModuleRoleMaps>"

# Merge: append only roles that are not mapped yet, never wipe existing maps
foreach ($role in $rolesXml.DocumentElement.ChildNodes) {
    $roleId = $role.GetAttribute('id')

    if ($null -eq $roleMapsNode.SelectSingleNode("Role[@id='$roleId']")) {
        $null = $roleMapsNode.AppendChild($appModuleXml.ImportNode($role, $true))
    }
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.OmitXmlDeclaration = $false
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)

$writer = [System.Xml.XmlWriter]::Create($appModuleXmlPath, $settings)
$appModuleXml.Save($writer)
$writer.Close()
