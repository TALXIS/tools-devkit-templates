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

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$groupNode = $entityXml.SelectSingleNode("//SiteMap/Area[@ResourceId='SitemapDesigner.areatitleexample']/Group[@ResourceId='SitemapDesigner.grouptitleexample']")

if (-not $groupNode) {
    Write-Error "Could not find the Group node in the SiteMap XML."
    exit 1
}

# Parameters injected by dotnet new template engine.
# Here-strings prevent apostrophes / special chars from breaking PS parsing.
$PageType = @'
__page-type__
'@

$Title = @'
__subarea-title__
'@

$EntityName = @'
entityexamplename
'@

$ViewId = @'
__view-id__
'@

$DashboardId = @'
__dashboard-id__
'@

$ControlName = @'
__control-name__
'@

$GenPageId = @'
__genpage-id__
'@

$CustomPageName = @'
__custom-page-name__
'@

$WebResourceName = @'
__webresource-name__
'@

$subareaId = "subarea_" + ([guid]::NewGuid().ToString() -split '-')[0]
$commonAttrs = "Client=`"All,Outlook,OutlookLaptopClient,OutlookWorkstationClient,Web`" AvailableOffline=`"true`" PassParams=`"false`" Sku=`"All,OnPremise,Live,SPLA`""
$escapedTitle = [System.Security.SecurityElement]::Escape($Title)
$titlesXml = "<Titles><Title LCID=`"1033`" Title=`"$escapedTitle`" /></Titles>"

switch ($PageType) {
    'entity' {
        if ([string]::IsNullOrWhiteSpace($EntityName)) {
            Write-Error "EntityLogicalName is required when PageType is 'entity'"
            exit 1
        }
        $subareaXmlString = "<SubArea Id=`"$subareaId`" Icon=`"/_imgs/imagestrips/transparent_spacer.gif`" Entity=`"$EntityName`" $commonAttrs>$titlesXml</SubArea>"
    }
    'entitylist' {
        if ([string]::IsNullOrWhiteSpace($EntityName)) {
            Write-Error "EntityLogicalName is required when PageType is 'entitylist'"
            exit 1
        }
        if ([string]::IsNullOrWhiteSpace($ViewId)) {
            Write-Error "ViewId is required when PageType is 'entitylist'"
            exit 1
        }
        $url = "/main.aspx?pagetype=entitylist&amp;etn=$EntityName&amp;viewid=$ViewId"
        $subareaXmlString = "<SubArea Id=`"$subareaId`" Icon=`"/_imgs/imagestrips/transparent_spacer.gif`" Url=`"$url`" $commonAttrs>$titlesXml</SubArea>"
    }
    'dashboard' {
        if ([string]::IsNullOrWhiteSpace($DashboardId)) {
            Write-Error "DashboardId is required when PageType is 'dashboard'"
            exit 1
        }
        $subareaXmlString = "<SubArea Id=`"$subareaId`" Icon=`"/_imgs/imagestrips/transparent_spacer.gif`" Url=`"/workplace/home_dashboards.aspx`" DefaultDashboard=`"$DashboardId`" $commonAttrs>$titlesXml</SubArea>"
    }
    'control' {
        if ([string]::IsNullOrWhiteSpace($ControlName)) {
            Write-Error "ControlName is required when PageType is 'control'"
            exit 1
        }
        $url = "/main.aspx?pagetype=control&amp;controlName=$ControlName"
        $subareaXmlString = "<SubArea Id=`"$subareaId`" Icon=`"/_imgs/imagestrips/transparent_spacer.gif`" Url=`"$url`" Entity=`"$EntityName`" $commonAttrs>$titlesXml</SubArea>"
    }
    'custom' {
        if ([string]::IsNullOrWhiteSpace($CustomPageName)) {
            Write-Error "CustomPageName is required when PageType is 'custom'"
            exit 1
        }
        $url = "/main.aspx?pagetype=custom&amp;name=$CustomPageName"
        $subareaXmlString = "<SubArea Id=`"$subareaId`" Icon=`"/_imgs/imagestrips/transparent_spacer.gif`" Url=`"$url`" $commonAttrs>$titlesXml</SubArea>"
    }
    'webresource' {
        if ([string]::IsNullOrWhiteSpace($WebResourceName)) {
            Write-Error "WebResourceName is required when PageType is 'webresource'"
            exit 1
        }
        $url = "/main.aspx?pagetype=webresource&amp;webresourceName=$WebResourceName"
        $subareaXmlString = "<SubArea Id=`"$subareaId`" Icon=`"/_imgs/imagestrips/transparent_spacer.gif`" Url=`"$url`" $commonAttrs>$titlesXml</SubArea>"
    }
    'genpage' {
        if ([string]::IsNullOrWhiteSpace($GenPageId)) {
            Write-Error "GenPageId is required when PageType is 'genpage'"
            exit 1
        }
        $subareaXmlString = "<SubArea Id=`"$subareaId`" GenPageId=`"$GenPageId`" VectorIcon=`"/_imgs/TableIconsFluentV9/document_one_page_sparkle.svg`" $commonAttrs>$titlesXml</SubArea>"
    }
    default {
        Write-Error "Unknown PageType: $PageType"
        exit 1
    }
}

[xml]$subareaXml = $subareaXmlString
$importedSubarea = $entityXml.ImportNode($subareaXml.DocumentElement, $true)
$groupNode.AppendChild($importedSubarea) | Out-Null

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()