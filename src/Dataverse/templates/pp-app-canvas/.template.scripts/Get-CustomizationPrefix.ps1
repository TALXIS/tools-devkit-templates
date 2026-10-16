$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

[xml]$xml = Get-Content -LiteralPath $solutionPath -Raw

$node = $xml.SelectSingleNode('//CustomizationPrefix')
if (-not $node) {
    Write-Error "<CustomizationPrefix> not found in $solutionPath"
    exit 1
}

$node.InnerText
