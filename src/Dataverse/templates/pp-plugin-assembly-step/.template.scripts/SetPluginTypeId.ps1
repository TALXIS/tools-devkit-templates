$assemblyName = "__assembly-name__"
$destinationFile = ".template.temp/__step-id__.xml"

# Search for the assembly data XML — supports both directory layouts.
$assemblyXml = Get-ChildItem -Path "__solution-root-path__/PluginAssemblies" -Filter "${assemblyName}.dll.data.xml" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($null -eq $assemblyXml) {
    Write-Error "Plugin assembly XML not found for '${assemblyName}' under __solution-root-path__/PluginAssemblies/. Ensure the solution has been built or pp-plugin-assembly has been run."
    exit 1
}

$sourceFile = $assemblyXml.FullName
[xml]$sourceXml = Get-Content $sourceFile
[xml]$destinationXml = Get-Content $destinationFile

$pluginType = $sourceXml.SelectSingleNode("//PluginType[contains(@AssemblyQualifiedName, '__plugin-class-name__')]")

if ($null -eq $pluginType) {
    Write-Error "Plugin class '__plugin-class-name__' not found in assembly XML at '$sourceFile'. Check the PluginName parameter matches a class in the compiled assembly."
    exit 1
}

$pluginTypeId = $pluginType.GetAttribute("PluginTypeId")

$destinationXml.SdkMessageProcessingStep.PluginTypeId = $pluginTypeId

$destinationXml.Save($destinationFile)
