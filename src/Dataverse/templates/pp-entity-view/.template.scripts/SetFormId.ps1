# Post-action script for pp-entity-view template.
#
# The template engine replaces "someexampleid" in the filename and XML content
# with a generated GUID. The template uses {someexampleid} (with literal braces)
# so the output already has {GUID}.xml filename and <savedqueryid>{GUID}</savedqueryid>.
#
# This script validates the result and falls back to adding braces if a view
# file without them is found (e.g. older template engine behavior).

$viewDir = Resolve-Path '__solution-root-path__/Entities/exampleexistingentity/SavedQueries'

# Check for view files without braces (need fixing)
$unbracedFile = Get-ChildItem -Path $viewDir -Filter "*.xml" -ErrorAction SilentlyContinue |
    Where-Object { $_.BaseName -notlike '{*' } |
    Select-Object -First 1

if ($null -eq $unbracedFile) {
    # All view files already have braces — nothing to do
    Write-Host "View GUID already has braces. No fixup needed."
    exit 0
}

# Fallback: add braces to filename and savedqueryid content
$viewId = [System.IO.Path]::GetFileNameWithoutExtension($unbracedFile.Name)
$bracedId = "{$viewId}"

[xml]$xml = Get-Content $unbracedFile.FullName -Raw
$idNode = $xml.SelectSingleNode("//savedqueryid")
if ($idNode) {
    $idNode.InnerText = $bracedId
}
$xml.Save($unbracedFile.FullName)

$newPath = Join-Path $viewDir "$bracedId.xml"
if ($unbracedFile.FullName -ne $newPath) {
    Rename-Item $unbracedFile.FullName $newPath
}
Write-Host "Fixed view GUID: $bracedId"