# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Customizations.xml'

[XML]$File = Get-Content -Path $solutionPath -Raw
$importExport = $File.SelectSingleNode("//ImportExportXml")

# The node is a shard marker for SolutionPackager - it must exist exactly once
if ($null -eq $importExport.SelectSingleNode("AppModuleSiteMaps")) {
    $null = $importExport.AppendChild($File.CreateElement("AppModuleSiteMaps"))
    $File.Save($solutionPath)
}
