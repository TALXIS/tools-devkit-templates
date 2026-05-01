$solutionXmlPath = (Resolve-Path 'SolutionDeclarationsRoot/Other/Solution.xml').Path
$content = Get-Content -Path $solutionXmlPath -Raw

# Collapse nil tags that the template engine splits across lines:
#   <Tag xsi:nil="true">\n      </Tag>  →  <Tag xsi:nil="true"></Tag>
$content = [regex]::Replace($content, '(xsi:nil="true")>\s*\n\s*</', '$1></')

[System.IO.File]::WriteAllText($solutionXmlPath, $content)
