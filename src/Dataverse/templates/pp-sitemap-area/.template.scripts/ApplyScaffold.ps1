$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to fill the rendered area id
# with a generated short id and append the area to the app's SiteMap element.

& txc workspace component apply-scaffold `
    --component-type 'SiteMapArea' `
    --file 'sitemap=__solution-root-path__/AppModuleSiteMaps/appexamplename/AppModuleSiteMap.xml' `
    --file 'area=.template.temp/area.xml'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.temp -Recurse -Force
Remove-Item .template.scripts -Recurse -Force
