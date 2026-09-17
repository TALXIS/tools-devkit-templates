$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to fill the rendered group id
# with a generated short id and append the group to the target sitemap area.

& txc workspace component apply-scaffold `
    --component-type 'SiteMapGroup' `
    --file 'sitemap=__solution-root-path__/AppModuleSiteMaps/appexamplename/AppModuleSiteMap.xml' `
    --file 'group=.template.temp/group.xml' `
    --param 'area-title=areatitleexample'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.temp -Recurse -Force
Remove-Item .template.scripts -Recurse -Force
