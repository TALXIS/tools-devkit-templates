$PluginProjectName = "examplepluginprojectname"
$plaginBuildName = $PluginProjectName.Replace(".", "")
$pluginguidIdExample = "pluginguididexample".ToUpper()
$sourceFile = "SolutionDeclarationsRoot\PluginAssemblies/${plaginBuildName}-${pluginguidIdExample}/${plaginBuildName}.dll.data.xml"
$destinationFile = ".template.temp/{pluginstepexampleid}.xml"

[xml]$sourceXml = Get-Content $sourceFile
[xml]$destinationXml = Get-Content $destinationFile

$pluginType = $sourceXml.SelectSingleNode("//PluginType[contains(@AssemblyQualifiedName, 'examplepluginname')]")

$pluginTypeId = $pluginType.GetAttribute("PluginTypeId")

$destinationXml.SdkMessageProcessingStep.PluginTypeId = $pluginTypeId

$destinationXml.Save($destinationFile)
