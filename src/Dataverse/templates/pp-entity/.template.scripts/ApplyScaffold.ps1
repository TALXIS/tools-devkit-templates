$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to register the entity (type 1,
# behavior from the Behavior choice) and rendered forms (type 60) in Solution.xml.
# Forms are registered in the order quick create, main, card, quick view.
# Sorts entity attributes by PhysicalName and collapses split xsi:nil tags.

& txc workspace component apply-scaffold `
    --component-type 'Entity' `
<!--#if (AddQuickCreateForm) -->
    --param 'quick-create-form-id=quickCreateFormId' `
<!--#endif -->
<!--#if (AddMainForm) -->
    --param 'main-form-id=mainFormId' `
<!--#endif -->
<!--#if (AddCardForm) -->
    --param 'card-form-id=cardFormId' `
<!--#endif -->
<!--#if (AddQuickForm) -->
    --param 'quick-form-id=quickFormId' `
<!--#endif -->
    --param 'entity=examplepublisherprefix_examplecustomentity' `
    --param 'behavior=behaviorType'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
