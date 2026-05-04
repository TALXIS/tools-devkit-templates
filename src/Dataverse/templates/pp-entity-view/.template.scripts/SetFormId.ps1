# The template engine has already:
# - Generated a GUID for ViewId
# - Replaced "someexampleid" in the filename and file contents
# This script wraps the GUID in braces for the savedqueryid element
# and renames the file to use braces (SolutionPackager convention).

$viewDir = Resolve-Path 'SolutionDeclarationsRoot/Entities/exampleexistingentity/SavedQueries'
# Filter out files that already have braces (existing views from pp-entity)
# so we only process the newly scaffolded view file.
$viewFile = Get-ChildItem -Path $viewDir -Filter "*.xml" -ErrorAction SilentlyContinue |
    Where-Object { $_.BaseName -notlike '{*' } |
    Select-Object -First 1

if ($null -eq $viewFile) {
    Write-Error "No view XML found in '$viewDir'."
    exit 1
}

$viewId = [System.IO.Path]::GetFileNameWithoutExtension($viewFile.Name)

# Wrap GUID in braces for the savedqueryid element
$bracedId = "{$viewId}"

[xml]$xml = Get-Content $viewFile.FullName -Raw
$idNode = $xml.SelectSingleNode("//savedqueryid")
if ($idNode) {
    $idNode.InnerText = $bracedId
}
$xml.Save($viewFile.FullName)

# Rename file to use braced GUID (SolutionPackager convention)
$newPath = Join-Path $viewDir "$bracedId.xml"
if ($viewFile.FullName -ne $newPath) {
    Rename-Item $viewFile.FullName $newPath
}