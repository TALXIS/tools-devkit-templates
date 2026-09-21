$ErrorActionPreference = 'Stop'

# Invokes txc workspace component apply-scaffold to derive the button logical name
# from its label, fill icon placeholders, create RibbonDiff.xml from the empty
# payload when missing, and append the command definition, localized labels and
# custom action. A here-string preserves apostrophes and other special characters in the label.

$ButtonLabel = @'
__button-label__
'@
$ButtonLabel = $ButtonLabel -replace "`r?`n\z", ""

$argsList = @(
    'workspace', 'component', 'apply-scaffold',
    '--component-type', 'RibbonButton',
    '--file', 'ribbon=__solution-root-path__/Entities/__entity-logical-name__/RibbonDiff.xml',
    '--file', 'empty-ribbon=.template.temp/ribbon-diff-empty.xml',
    '--file', 'command-definition=.template.temp/command-definition.xml',
    '--file', 'loc-labels=.template.temp/loc-labels.xml',
    '--file', 'custom-action=.template.temp/custom-action.xml',
    '--param', "button-label=$ButtonLabel",
    '--param', 'icon-16=__image-16x16__',
    '--param', 'icon-32=__image-32x32__',
    '--param', 'modern-image=__modern-image__'
)
& txc @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item .template.temp -Recurse -Force
Remove-Item .template.scripts -Recurse -Force
