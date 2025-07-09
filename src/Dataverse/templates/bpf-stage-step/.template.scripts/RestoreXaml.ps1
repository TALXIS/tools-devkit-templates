$folder  = (Resolve-Path 'SolutionDeclarationsRoot\Workflows').Path

$xamlFile = Get-ChildItem -Path $folder -Filter *.xaml | Select-Object -First 1

if ($xamlFile -eq $null) {
    exit
}

$content = Get-Content $xamlFile.FullName -Raw

$patterns = @(
    'xmlns:mxswa="clr-namespace:Microsoft\.Crm\.Workflow\.Activities;assembly=Microsoft\.Crm\.Workflow"',
    'xmlns:sco="clr-namespace:System\.Collections\.ObjectModel;assembly=mscorlib"',
    'xmlns=""',
    'xmlns:mcwb="clr-namespace:Microsoft\.Crm\.Workflow\.BusinessEntities;assembly=Microsoft\.Crm\.Workflow"',
    'xmlns:mcwo="clr-namespace:Microsoft\.Crm\.Workflow\.Objects;assembly=Microsoft\.Crm\.Workflow"'
)

foreach ($pattern in $patterns) {
    $regex = "$pattern\s*"
    $content = [regex]::Replace($content, $regex, "", "IgnoreCase")
}

Remove-Item $xamlFile.FullName -Force

Set-Content -Path $xamlFile.FullName -Value $content -Encoding UTF8
