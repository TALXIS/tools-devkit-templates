﻿param(
    [Parameter()]
    [string]$FormGuidId,

    [Parameter(Mandatory=$true)]
    [string]$Formtype
)

# --- Path Validation ---
# Resolve template path relative to script
$attributeXmlPath = Join-Path -Path $PSScriptRoot -ChildPath '.template.temp\row.xml'
if (-not (Test-Path -Path $attributeXmlPath -PathType Leaf)) {
    throw "Template file not found at: $attributeXmlPath"
}

# Resolve base declarations path relative to script
$declarationsBase = Join-Path -Path $PSScriptRoot -ChildPath 'Declarations\Entities'
if (-not (Test-Path -Path $declarationsBase -PathType Container)) {
    throw "Declarations base directory not found at: $declarationsBase"
}

# Find the FormXml directory (add error handling if multiple/none found)
$formXmlFolder = Get-ChildItem -Path (Join-Path -Path $declarationsBase -ChildPath '*\FormXml') -Directory | Select-Object -First 1
if ($null -eq $formXmlFolder) {
    throw "Could not find FormXml directory under $declarationsBase"
}

$formFolder = Join-Path $formXmlFolder.FullName $Formtype
if (-not (Test-Path -Path $formFolder -PathType Container)) {
    throw "Form type directory not found at: $formFolder"
}

# --- Find Target XML File ---
$xmlFile = $null
if ([string]::IsNullOrEmpty($FormGuidId)) {
    # Find the first XML file if no GUID provided
    $xmlFile = Get-ChildItem -Path $formFolder -Filter *.xml -File | Select-Object -First 1
    if ($null -eq $xmlFile) {
        throw "No XML files found in folder '$formFolder'"
    }
} else {
    # Construct search pattern based on GUID format
    $searchPattern = if ($FormGuidId.StartsWith('{')) { "$FormGuidId.*" } else { "{$FormGuidId}.*" }

    # Find file(s) matching the GUID pattern (Corrected variable name, removed ErrorAction)
    $foundFiles = Get-ChildItem -Path $formFolder -Filter $searchPattern -File
    if ($null -eq $foundFiles) {
       throw "No XML file found matching pattern '$searchPattern' in folder '$formFolder'"
    }

    # Handle potential multiple matches if necessary, here we just take the first
    $xmlFile = $foundFiles | Select-Object -First 1
}

$entityXmlPath = $xmlFile.FullName
# Final check on the resolved target file path
if (-not (Test-Path -Path $entityXmlPath -PathType Leaf)) {
     throw "Target XML file not found or inaccessible at: $entityXmlPath"
}

Write-Host "INFO: Target XML file: $entityXmlPath"
Write-Host "INFO: Template XML file: $attributeXmlPath"

# --- XML Processing ---
try {
    [XML]$mainXml = Get-Content -Path $entityXmlPath -Raw
    [XML]$newRowXml = Get-Content -Path $attributeXmlPath -Raw
} catch {
    throw "Error loading XML content. Check file paths and content. Error: $($_.Exception.Message)"
}

$newRow = $newRowXml.DocumentElement
if ($null -eq $newRow) {
    throw "Could not get DocumentElement from template file: $attributeXmlPath"
}

# Select the target node for insertion
$rowsNode = $mainXml.forms.systemform.form.tabs.tab.columns.column.sections.section.rows
if ($null -eq $rowsNode) {
    throw "Could not find the target <rows> node in the XML file: $entityXmlPath. Check XML structure."
}

# Import and append the new row
$importedRow = $mainXml.ImportNode($newRow, $true)
if ($null -eq $importedRow) {
    throw "Failed to import node from template XML."
}
$rowsNode.AppendChild($importedRow) | Out-Null

# --- Save Modified XML ---
# Configure XmlWriter settings
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling =::None # Retain original formatting where possible
$settings.OmitXmlDeclaration = $false # Keep the <?xml...?> declaration

$writer = $null
try {
    $writer =::Create($entityXmlPath, $settings)
    $mainXml.Save($writer)
    Write-Host "INFO: Successfully modified and saved XML file: $entityXmlPath"
} catch {
    throw "Error saving modified XML to '$entityXmlPath'. Error: $($_.Exception.Message)"
} finally {
    if ($null -ne $writer) {
        $writer.Close()
    }
}