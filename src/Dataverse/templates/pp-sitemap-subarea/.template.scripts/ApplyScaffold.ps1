$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to build the SubArea for the
# requested page type and append it to the target group. A here-string preserves
# apostrophes and other special characters in the title. Optional per-page-type
# parameters are passed only when populated.

$Title = @'
__subarea-title__
'@
$Title = $Title -replace "`r?`n\z", ""

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'SiteMapSubArea',
    '--file', 'sitemap=__solution-root-path__/AppModuleSiteMaps/appexamplename/AppModuleSiteMap.xml',
    '--param', 'area-title=areatitleexample',
    '--param', 'group-title=grouptitleexample',
    '--param', 'page-type=__page-type__',
    '--param', "subarea-title=$Title"
)
if ('entityexamplename' -ne '') { $argsList += @('--param', 'entity=entityexamplename') }
if ('__view-id__' -ne '') { $argsList += @('--param', 'view-id=__view-id__') }
if ('__dashboard-id__' -ne '') { $argsList += @('--param', 'dashboard-id=__dashboard-id__') }
if ('__control-name__' -ne '') { $argsList += @('--param', 'control-name=__control-name__') }
if ('__genpage-id__' -ne '') { $argsList += @('--param', 'genpage-id=__genpage-id__') }
if ('__custom-page-name__' -ne '') { $argsList += @('--param', 'custom-page-name=__custom-page-name__') }
if ('__webresource-name__' -ne '') { $argsList += @('--param', 'webresource-name=__webresource-name__') }

& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
