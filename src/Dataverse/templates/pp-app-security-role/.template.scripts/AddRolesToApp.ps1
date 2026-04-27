$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot/AppModules/appexamplename/AppModule.xml').Path
$privilegesPath = (Resolve-Path '.template.scripts/appaccess.xml').Path


[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$rootNode = $entityXml.SelectSingleNode('//AppModule')
if (-not $rootNode) {
    Write-Error "AppModule root not found"
    exit 1
}

$existingRolesNode = $rootNode.SelectSingleNode('AppModuleRoleMaps')
if ($existingRolesNode) {
    $rootNode.RemoveChild($existingRolesNode) | Out-Null
}

$privilegesRaw = Get-Content -Path $privilegesPath -Raw
$wrapped = "<AppModuleRoleMaps>$privilegesRaw</AppModuleRoleMaps>"
[xml]$rolesXml = $wrapped

$importedNode = $entityXml.ImportNode($rolesXml.AppModuleRoles, $true)
$rootNode.AppendChild($importedNode) | Out-Null

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.OmitXmlDeclaration = $false
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()
