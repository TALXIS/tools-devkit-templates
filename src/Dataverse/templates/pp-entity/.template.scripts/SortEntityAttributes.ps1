. "$PSScriptRoot/Save-TxcXml.ps1"

$entityXmlPaths = Get-ChildItem -Path "__solution-root-path__/Entities" -Recurse -File -Filter "Entity.xml" -ErrorAction SilentlyContinue
if (-not $entityXmlPaths) { exit 0 }

foreach ($entityXmlFile in $entityXmlPaths) {
    [xml]$xml = Get-Content -Path $entityXmlFile.FullName -Raw

    $attributesNodes = $xml.SelectNodes('//entity/attributes')
    foreach ($attributesNode in $attributesNodes) {
        $attrs = @($attributesNode.SelectNodes('attribute'))
        if ($attrs.Count -eq 0) { continue }

        $sorted = $attrs | Sort-Object { $_.GetAttribute('PhysicalName').ToLowerInvariant() }

        foreach ($a in $attrs) {
            $attributesNode.RemoveChild($a) | Out-Null
        }
        foreach ($a in $sorted) {
            $attributesNode.AppendChild($a) | Out-Null
        }
    }
    Save-TxcXml -Document $xml -Path $entityXmlFile.FullName -ExpandEmptyElements @(
    'AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor',
    'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask'
)
}
