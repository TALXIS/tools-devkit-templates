# Find Solution.xml — may be in SolutionDeclarationsRoot/Other or Other depending on flattening
$candidates = @(
    'SolutionDeclarationsRoot/Other/Solution.xml',
    'Other/Solution.xml'
)

$solutionXmlPath = $null
foreach ($c in $candidates) {
    if (Test-Path $c) {
        $solutionXmlPath = (Resolve-Path $c).Path
        break
    }
}

if (-not $solutionXmlPath) {
    Write-Warning "Solution.xml not found, skipping nil tag normalization"
    exit 0
}

$content = [System.IO.File]::ReadAllText($solutionXmlPath)

# Collapse nil tags split across lines by template engine:
#   <Tag xsi:nil="true">\n      </Tag>  →  <Tag xsi:nil="true"></Tag>
$content = [regex]::Replace($content, '(xsi:nil="true")>\s*\r?\n\s*</', '$1></')

[System.IO.File]::WriteAllText($solutionXmlPath, $content)
