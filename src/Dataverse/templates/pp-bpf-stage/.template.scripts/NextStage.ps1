$xamlPath = ".template.temp\stage.xaml"

$isThisaLastStage = isThisaLastStage

if ($isThisaLastStage) {
    $content = Get-Content $xamlPath -Raw

    $content = $content -replace 'nextstageidexample', 'null'

    Set-Content -Path $xamlPath -Value $content
} 