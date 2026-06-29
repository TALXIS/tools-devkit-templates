# Normalize nil XML tags to match SolutionPackager export format
# Template engine splits <Tag xsi:nil="true"></Tag> across two lines

$solutionXml = Get-ChildItem -Path . -Filter Solution.xml -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $solutionXml) {
    Write-Warning "Solution.xml not found, skipping nil tag normalization"
    exit 0
}

$content = [System.IO.File]::ReadAllText($solutionXml.FullName)
$content = [regex]::Replace($content, '(xsi:nil="true")>\s*\r?\n\s*</', '$1></')
$content = $content.Replace("`r`n", "`n").Replace("`r", "`n")
[System.IO.File]::WriteAllText($solutionXml.FullName, $content, [System.Text.UTF8Encoding]::new($false))
