$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to stamp the form id, rename
# the file to {id}.xml, fill the dialog unique name and register the form in
# Solution.xml. Dialog registrations omit the behavior attribute. Quick create
# forms are located by their rendered file names.

& txc workspace component apply-scaffold `
    --component-type 'EntityForm' `
<!--#if (FormType == "dialog") -->
    --file 'form=__solution-root-path__/Dialogs/dialogform.xml' `
<!--#elseif (FormType == "quickCreate") -->
    --file 'form=__solution-root-path__/Entities/ItemFolderName/FormXml/quick/{formexampleId}.xml' `
<!--#else -->
    --file 'form=__solution-root-path__/Entities/ItemFolderName/FormXml/main/mainform.xml' `
<!--#endif -->
    --param 'form-type=formtypeexample' `
    --param 'form-id=formexampleId' `
    --param 'form-name=formexamplename' `
    --param 'dialog-unique-name=dialogexampleuniquename' `
    --param 'entity=ItemFolderName'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
