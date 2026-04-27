$XmlFilePath = ".template.temp\customcontrolparameters.xml"

[xml]$xmlDoc = Get-Content $XmlFilePath -Raw
    
$nodesToRemove = $xmlDoc.SelectNodes("//*[normalize-space(text())='defaulttemplateexample']")
$nodesToRemove += $xmlDoc.SelectNodes("//*[normalize-space(text())='{defaulttemplateexample}']")
    
for ($i = $nodesToRemove.Count - 1; $i -ge 0; $i--) {
    $node = $nodesToRemove[$i]
    
    $node.ParentNode.RemoveChild($node) | Out-Null
}
    
$xmlDoc.Save($XmlFilePath)
    