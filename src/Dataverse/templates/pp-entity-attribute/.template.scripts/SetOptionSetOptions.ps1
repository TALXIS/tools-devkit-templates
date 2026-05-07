$optionSetOptionXmlPath = (Resolve-Path '.template.temp/optionsetoption.xml').Path
[xml]$optionSetOptionTemplate = Get-Content -Path $optionSetOptionXmlPath -Raw

$optionNumber = (Get-Random -Minimum 10000 -Maximum 99999) * 10000

$attributeXmlPath 

<!--#if (AttributeType == "OptionSet(Global)") -->
    $attributeXmlPath = "__solution-root-path__/OptionSets/__attribute-schema-name__.xml"
<!--#endif -->

<!--#if (AttributeType == "OptionSet(Local)") -->
    $attributeXmlPath = ".template.temp/attribute.xml"
<!--#endif -->

[xml]$attributeXml = Get-Content -Path $attributeXmlPath -Raw

$options = "__option-set-options__"
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
    
    $optionXmlString = $optionXmlString -replace "__option-number__", $optionNumber
    $optionXmlString = $optionXmlString -replace "__option-name__", $option
    
    
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

<!--#if (AttributeType == "OptionSet(Global)") -->
    # Resolve the relative path to an absolute path (to support other OSes)
    $solutionPath = Resolve-Path -Path '__solution-root-path__/Other/Solution.xml'

    # Load the XML file
    [XML]$File = Get-Content -Path $solutionPath -Raw
    $rootComponents = $File.SelectSingleNode("//RootComponents")

    $schemaName = '__attribute-schema-name__'
    $existingComponent = $File.SelectSingleNode("//RootComponent[@type='9' and @schemaName='$schemaName']")

    if ($existingComponent -eq $null) {
        $newComponent = $File.CreateElement("RootComponent")
        $newComponent.SetAttribute("type", '9')
        $newComponent.SetAttribute("schemaName", $schemaName)
        $newComponent.SetAttribute("behavior", '0')

        # Append the new component to the root components without writing output to console
        $null = $rootComponents.AppendChild($newComponent)
    }

    # Save the updated XML back to the file
    $File.Save($solutionPath)
<!--#endif -->
