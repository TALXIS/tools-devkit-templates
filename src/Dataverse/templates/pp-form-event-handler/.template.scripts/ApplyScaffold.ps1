$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to register the JavaScript library
# (except for dialogs) and attach the event handler with the supplied PassExecutionContext value.

& txc workspace component apply-scaffold `
    --component-type 'FormEventHandler' `
    --param 'entity=exampleentityname' `
    --param 'form-type=formtypeexample' `
    --param 'form-id=formguididexample' `
    --param 'library-name=examplelibraryname.js' `
    --param 'library-unique-id=examplelibraryuniqueid' `
    --param 'event-name=exampleeventname' `
    --param 'attribute-name=exampleattributename' `
    --param 'function-name=examplefunctionname' `
    --param 'handler-unique-id=examplehandleruniqueid' `
    --param 'pass-execution-context=examplepassexecutioncontext'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
