$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to register AppModule (type 80)
# and SiteMap (type 62) root components and fill sitemap placeholders with generated short ids.

& txc workspace component apply-scaffold `
    --component-type 'AppModule' `
    --file 'sitemap=__solution-root-path__/AppModuleSiteMaps/userprefixexample_appexamplename/AppModuleSiteMap.xml' `
    --param 'app-name=userprefixexample_appexamplename'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
