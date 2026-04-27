$entityXmlRelativePaths = @(
    'SolutionDeclarationsRoot/AppModuleSiteMaps/appexamplename/AppModuleSiteMap.xml'
    'SolutionDeclarationsRoot/AppModuleSiteMaps/appexamplename/AppModuleSiteMap_managed.xml'
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
    exit 1
}

$groupPath = (Resolve-Path '.template.temp/group.xml').Path


[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw
[xml]$groupXml = Get-Content -Path $groupPath -Raw

$areaNode = $entityXml.SelectSingleNode("//SiteMap/Area[@ResourceId='SitemapDesigner.areatitleexample']")

if (-not $areaNode) {
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
