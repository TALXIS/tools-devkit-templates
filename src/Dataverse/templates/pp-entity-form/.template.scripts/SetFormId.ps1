$formId = "formexampleId"

<!--#if (FormType == "dialog") -->
$formIdNode = "//FormId"
$formIdPath = (Resolve-Path './SolutionDeclarationsRoot/Dialogs/dialogform.xml').Path
<!--#else -->
$formIdNode = "//formid"
$formIdPath = (Resolve-Path './SolutionDeclarationsRoot/Entities/ItemFolderName/FormXml/formtypeexample/mainform.xml').Path
<!--#endif -->

# Generate GUID if formId is "unknown"
if ($formId -eq "unknown") {
    $formId = [System.Guid]::NewGuid()
    Write-Host "Generated new form ID: $formId"
}

# Check if the file exists
if (-not (Test-Path $formIdPath)) {
    Write-Error "Form file not found at: $formIdPath"
    exit 1
}

$formId = "{$formId}"

# Generate new file name with the form ID
$directory = Split-Path $formIdPath -Parent
$newFileName = "$formId.xml"
$newFilePath = Join-Path $directory $newFileName

# Load the XML file
[xml]$formXml = Get-Content $formIdPath -Raw

# Find and replace formguididexample with the actual form ID
$formGuidNode = $formXml.SelectSingleNode($formIdNode)
if ($formGuidNode) {
    $formGuidNode.InnerText = $formId
    Write-Host "Updated formid to: $formId"
} else {
    Write-Warning "formid node not found in XML"
}

# Save the updated XML to the new file
$formXml.Save($newFilePath)
Write-Host "Saved updated form to: $newFilePath"

# Remove the old file if it has a different name
if ($formIdPath -ne $newFilePath) {
    Remove-Item $formIdPath -Force
    Write-Host "Removed old file: $formIdPath"
}

.\.template.scripts\AddFormToSolutionXml.ps1 -formId $formId