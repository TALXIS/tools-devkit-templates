. "$PSScriptRoot/Save-TxcXml.ps1"

$ErrorActionPreference = 'Stop'

# Path to the generated environment variable definition XML
$definitionXmlPath = "__solution-root-path__/environmentvariabledefinitions/__schema-name__/environmentvariabledefinition.xml"

if (-not (Test-Path $definitionXmlPath)) {
    Write-Error "environmentvariabledefinition.xml not found at $definitionXmlPath"
    exit 1
}

[xml]$definitionXml = Get-Content -Path $definitionXmlPath -Raw

$rootNode = $definitionXml.environmentvariabledefinition

# Drop <defaultvalue> when DefaultValue parameter was left blank.
# The XML template ships the element with text "__default-value__" already replaced; an empty
# replacement leaves the element present but empty, which is semantically different from "no default".
$defaultValueNode = $rootNode.SelectSingleNode("defaultvalue")
if ($defaultValueNode -and [string]::IsNullOrEmpty($defaultValueNode.InnerText)) {
    $rootNode.RemoveChild($defaultValueNode) | Out-Null
}

# Drop <description> when Description parameter was left blank.
$descriptionNode = $rootNode.SelectSingleNode("description")
if ($descriptionNode -and [string]::IsNullOrEmpty($descriptionNode.GetAttribute("default"))) {
    $rootNode.RemoveChild($descriptionNode) | Out-Null
}

# Re-write with stable formatting.
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = '  '
$settings.NewLineHandling = [System.Xml.NewLineHandling]::Replace
$settings.OmitXmlDeclaration = $true
$settings.Encoding = New-Object System.Text.UTF8Encoding($false)

Save-TxcXml -Document $definitionXml -Path $definitionXmlPath -ExpandEmptyElements @('AutoNumberFormat', 'Format', 'ExternalName', 'EntityColor', 'MobileOfflineFilters', 'IconVectorName', 'EntityHelpUrl', 'ActivityTypeMask', 'ExternalTypeName', 'RibbonTemplates', 'CustomActions')
