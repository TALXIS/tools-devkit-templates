. "$PSScriptRoot/Save-TxcXml.ps1"

<!--#if (ParameterType == "Custom") -->
$XmlFilePath = ".template.temp\customcontrolparameters.xml"
<!--#else -->
$XmlFilePath = ".template.temp\parameters.xml"
<!--#endif -->

[xml]$xmlDoc = Get-Content $XmlFilePath -Raw
    
$nodesToRemove = $xmlDoc.SelectNodes("//*[normalize-space(text())='defaultеtemplateexample']")
$nodesToRemove += $xmlDoc.SelectNodes("//*[normalize-space(text())='{defaultеtemplateexample}']")
    
for ($i = $nodesToRemove.Count - 1; $i -ge 0; $i--) {
    $node = $nodesToRemove[$i]
    
    $node.ParentNode.RemoveChild($node) | Out-Null
}
    
Save-TxcXml -Document $xmlDoc -Path $XmlFilePath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')
    