$ButtonLabel = "examplebuttonlable"

$commanddefinitionPath = (Resolve-Path './.template.temp/commanddefinition.xml').Path
$loclbelsPath = (Resolve-Path './.template.temp/loclbels.xml').Path
$customactionPath = (Resolve-Path './.template.temp/customaction.xml').Path

$logicalName = $ButtonLabel -replace '[\p{P}\p{S}]', ''
$logicalName = $logicalName -replace '\s', ''
$logicalName = $logicalName.ToLower()

$files = @($commanddefinitionPath, $loclbelsPath, $customactionPath)

foreach ($file in $files) {
    $content = Get-Content -Path $file -Raw
    $content = $content -replace 'examplebuttonlogicalname', $logicalName
    Set-Content -Path $file -Value $content
}