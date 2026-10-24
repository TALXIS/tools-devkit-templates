$ErrorActionPreference = 'Stop'

$customizationsPath = '__solution-root-path__/Other/Customizations.xml'
if (-not (Test-Path $customizationsPath)) {
    Write-Error "Customizations.xml not found at $customizationsPath"
    exit 1
}

$connectorName = '__connector-name__'
$logicalName = '__logical-name__'
if ([string]::IsNullOrWhiteSpace($logicalName)) {
    $logicalName = '__publisher-prefix__' + '_' + ($connectorName -replace '_', '')
}
$logicalName = $logicalName.ToLowerInvariant()

if ($logicalName -notmatch '^[a-z][a-z0-9]*_[a-z0-9_]+$') {
    Write-Error "Connection reference logical name '$logicalName' must be lowercase letters, digits and underscores, starting with the publisher prefix."
    exit 1
}

$displayName = '__display-name__'
if ([string]::IsNullOrWhiteSpace($displayName)) { $displayName = $logicalName }

$resolvedPath = (Resolve-Path -Path $customizationsPath).Path
[xml]$file = Get-Content -Path $resolvedPath -Raw
$root = $file.SelectSingleNode('//ImportExportXml')

$references = $root.SelectSingleNode('connectionreferences')
if ($null -eq $references) {
    $references = $file.CreateElement('connectionreferences')
    # Exported solutions place <connectionreferences> right before <Languages>.
    $languages = $root.SelectSingleNode('Languages')
    if ($null -ne $languages) {
        $null = $root.InsertBefore($references, $languages)
    } else {
        $null = $root.AppendChild($references)
    }
}

if ($null -ne $references.SelectSingleNode("connectionreference[@connectionreferencelogicalname='$logicalName']")) {
    Write-Host "Connection reference '$logicalName' already declared in Customizations.xml."
    return
}

$reference = $file.CreateElement('connectionreference')
$reference.SetAttribute('connectionreferencelogicalname', $logicalName)

$children = [ordered]@{
    connectionreferencedisplayname = $displayName
    connectorid                    = "/providers/Microsoft.PowerApps/apis/$connectorName"
    iscustomizable                 = '1'
    statecode                      = '0'
    statuscode                     = '1'
}
foreach ($name in $children.Keys) {
    $child = $file.CreateElement($name)
    $child.InnerText = $children[$name]
    $null = $reference.AppendChild($child)
}

$null = $references.AppendChild($reference)
$file.Save($resolvedPath)
Write-Host "Declared connection reference '$logicalName' for connector '$connectorName'."
