$entityXmlPath = (Resolve-Path '__solution-root-path__/AppModules/appexamplename/AppModule.xml').Path
$privilegesPath = (Resolve-Path '.template.scripts/appaccess.xml').Path


[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$rootNode = $entityXml.SelectSingleNode('//AppModule')
if (-not $rootNode) {
    Write-Error "AppModule root not found"
    exit 1
}

$privilegesRaw = Get-Content -Path $privilegesPath -Raw
if ([string]::IsNullOrWhiteSpace($privilegesRaw)) {
    Write-Error "No security roles were generated. Check that SecurityRolesIds contains at least one role GUID."
    exit 1
}

$wrapped = "<AppModuleRoleMaps>$privilegesRaw</AppModuleRoleMaps>"
[xml]$rolesXml = $wrapped

# The wrapper element is <AppModuleRoleMaps>; address it via DocumentElement so
# the node name only has to be correct in one place.
$newRolesNode = $rolesXml.DocumentElement
if (-not $newRolesNode) {
    Write-Error "Could not parse generated role maps from $privilegesPath"
    exit 1
}

$importedNode = $entityXml.ImportNode($newRolesNode, $true)

# Only drop the existing role map once the replacement is known to be good,
# so a failure here cannot leave the app module without any roles.
$existingRolesNode = $rootNode.SelectSingleNode('AppModuleRoleMaps')
if ($existingRolesNode) {
    $rootNode.RemoveChild($existingRolesNode) | Out-Null
}

$rootNode.AppendChild($importedNode) | Out-Null

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.OmitXmlDeclaration = $false
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()
