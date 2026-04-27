$optionSetOptionXmlPath = (Resolve-Path '.template.temp/optionsetoption.xml').Path
[xml]$optionSetOptionTemplate = Get-Content -Path $optionSetOptionXmlPath -Raw

$optionNumber = (Get-Random -Minimum 10000 -Maximum 99999) * 10000

$attributeXmlPath 

$attributeXmlPath = "SolutionDeclarationsRoot/OptionSets/examplepublisherprefix_examplecustomentityattribute.xml"

[xml]$attributeXml = Get-Content -Path $attributeXmlPath -Raw

$options = "optinsforoptionsetexample"
$options = $options.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Replace('{', '').Replace('}', '') }

$optionsNode = $attributeXml.SelectSingleNode("//options")
if ($optionsNode -eq $null) {
    Write-Error "Options node not found in attribute.xml"
    exit 1
}

if ($optionsNode.IsEmpty) {
    $optionsetNode = $optionsNode.ParentNode
    $optionsetNode.RemoveChild($optionsNode)
    
    $newOptionsNode = $attributeXml.CreateElement("options")
    $optionsetNode.AppendChild($newOptionsNode) | Out-Null
    $optionsNode = $newOptionsNode
} 

foreach ($option in $options) {
    
    $newOptionNode = $optionSetOptionTemplate.DocumentElement.CloneNode($true)
    
    $optionXmlString = $newOptionNode.OuterXml
    
    $optionXmlString = $optionXmlString -replace "exampleoptionnumber", $optionNumber
    $optionXmlString = $optionXmlString -replace "exampleoptionname", $option
    
    
    [xml]$updatedOptionXml = $optionXmlString
    
    $importedNode = $attributeXml.ImportNode($updatedOptionXml.DocumentElement, $true)
    $optionsNode.AppendChild($importedNode) | Out-Null
    
    $optionNumber++
}


$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false
$settings.Encoding = [System.Text.Encoding]::UTF8

$writer = [System.Xml.XmlWriter]::Create($attributeXmlPath, $settings)
$attributeXml.Save($writer)
$writer.Close()

# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = Resolve-Path -Path 'SolutionDeclarationsRoot/Other/Solution.xml'

# Load the XML file
[XML]$File = Get-Content -Path $solutionPath -Raw
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '9')
$newComponent.SetAttribute("schemaName", 'examplepublisherprefix_examplecustomentityattribute')
$newComponent.SetAttribute("behavior", '0')

# Append the new component to the root components without writing output to console
$null = $rootComponents.AppendChild($newComponent)

# Save the updated XML back to the file
$File.Save($solutionPath)