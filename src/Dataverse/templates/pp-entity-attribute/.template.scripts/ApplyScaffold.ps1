$ErrorActionPreference = 'Stop'

# Single interim post-action: all XML mutations run in-process inside the TALXIS CLI
# (txc workspace component apply-scaffold), backed by the platform metadata library.

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'Attribute',
    '--solution-root', '__solution-root-path__',
    '--file', 'attribute=.template.temp/attribute.xml',
    '--param', 'entity=__entity-schema-name__'
)

<!--#if (AttributeType == "OptionSet(Local)" || AttributeType == "OptionSet(LocalMulti)") -->
$argsList += @('--param', 'options=__option-set-options__')
<!--#endif -->

<!--#if ((AttributeType == "OptionSet(Global)" || AttributeType == "OptionSet(GlobalMulti)") && (OptionSetType == "New")) -->
$argsList += @('--param', 'options=__option-set-options__')
$argsList += @('--file', 'global-optionset=__solution-root-path__/OptionSets/__attribute-schema-name__.xml')
<!--#if (OptionSetNameIsOverridden) -->
$argsList += @('--param', 'global-optionset-name=__global-optionset-name-override__')
<!--#else -->
$argsList += @('--param', 'global-optionset-name=__attribute-schema-name__')
<!--#endif -->
<!--#endif -->

<!--#if (AttributeType == "Money") -->
$argsList += @(
    '--file', 'money-base=.template.temp/money-base-attribute.xml',
    '--file', 'currency=.template.temp/transactioncurrency-attribute.xml',
    '--file', 'exchange-rate=.template.temp/exchangerate-attribute.xml'
)
<!--#endif -->

<!--#if (AddLookupRelationship) -->
$argsList += @(
    '--file', 'relationship=.template.temp/lookup-relationship.xml',
    '--param', 'relationship-name=__lookup-relationship-name__',
    '--param', 'referenced-entity=__referenced-entity-name__'
)
<!--#endif -->

& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.scripts -Recurse -Force
Remove-Item .template.temp -Recurse -Force
