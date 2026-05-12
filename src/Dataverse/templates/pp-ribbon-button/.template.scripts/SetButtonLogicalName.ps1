$ButtonLabel = "__button-label__"

$commanddefinitionPath = (Resolve-Path './.template.temp/command-definition.xml').Path
$loclbelsPath = (Resolve-Path './.template.temp/loc-labels.xml').Path
$customactionPath = (Resolve-Path './.template.temp/custom-action.xml').Path

$logicalName = $ButtonLabel -replace '[\p{P}\p{S}]', ''
$logicalName = $logicalName -replace '\s', ''
$logicalName = $logicalName.ToLower()

$files = @($commanddefinitionPath, $loclbelsPath, $customactionPath)

foreach ($file in $files) {
    $content = Get-Content -Path $file -Raw
    $content = $content -replace '__button-logical-name__', $logicalName
    Set-Content -Path $file -Value $content
}