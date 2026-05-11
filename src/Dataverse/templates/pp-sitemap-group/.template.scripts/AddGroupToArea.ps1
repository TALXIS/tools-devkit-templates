$entityXmlRelativePaths = @(
    '__solution-root-path__/AppModuleSiteMaps/appexamplename/AppModuleSiteMap.xml'
    '__solution-root-path__/AppModuleSiteMaps/appexamplename/AppModuleSiteMap_managed.xml'
)

$entityXmlPath = $null
foreach ($candidatePath in $entityXmlRelativePaths) {
    $resolvedPath = Resolve-Path $candidatePath -ErrorAction SilentlyContinue
    if ($resolvedPath) {
        $entityXmlPath = $resolvedPath.Path
        break
    }
}

if (-not $entityXmlPath) {
    Write-Error "Could not find the SiteMap XML file. Check that the file exists and the path parameters are correct."
    exit 1
}

$groupPath = (Resolve-Path '.template.temp/group.xml').Path


[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw
[xml]$groupXml = Get-Content -Path $groupPath -Raw

$areaNode = $entityXml.SelectSingleNode("//SiteMap/Area[@ResourceId='SitemapDesigner.areatitleexample']")

if (-not $areaNode) {
    Write-Error "Could not find the Area node in the SiteMap XML."
    exit 1
}

$importedGroup = $entityXml.ImportNode($groupXml.DocumentElement, $true)
$areaNode.AppendChild($importedGroup) | Out-Null

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()
