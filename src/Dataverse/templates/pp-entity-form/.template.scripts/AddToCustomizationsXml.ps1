# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = (Resolve-Path -Path '__solution-root-path__/Other/Customizations.xml').Path

# Load with whitespace preserved so only the new Dialogs line changes
$File = New-Object System.Xml.XmlDocument
$File.PreserveWhitespace = $true
$File.Load($solutionPath)
$root = $File.SelectSingleNode("//ImportExportXml")

# Ensure Dialogs node exists once; add only if missing
$existingDialogs = $File.SelectSingleNode("//ImportExportXml/Dialogs")
if (-not $existingDialogs) {
    $newComponent = $File.CreateElement("Dialogs")
    # Keep the closing </ImportExportXml> on its own line by inserting before trailing whitespace
    $trailing = $root.LastChild
    if ($trailing -is [System.Xml.XmlWhitespace]) {
        $null = $root.InsertBefore($File.CreateWhitespace("`n  "), $trailing)
        $null = $root.InsertBefore($newComponent, $trailing)
    } else {
        $null = $root.AppendChild($File.CreateWhitespace("`n  "))
        $null = $root.AppendChild($newComponent)
        $null = $root.AppendChild($File.CreateWhitespace("`n"))
    }
    $File.Save($solutionPath)
}
