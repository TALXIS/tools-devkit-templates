$entityXmlPath = (Resolve-Path 'SolutionDeclarationsRoot\Entities\exampleentityname\FormXml\exampleformtype\{formguididexample}.xml').Path

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$eventsNode = $entityXml.SelectSingleNode('//events')
if (-not $eventsNode) {
	$entityXml.SelectSingleNode('//form').AppendChild($entityXml.CreateElement('events')) | Out-Null
	$eventsNode = $entityXml.SelectSingleNode('//events')
}

# If formLibraries already contains the library, skip adding it
$eventName = 'exampleeventname'
$attributeName = 'exampleattributename'
if ($eventname -eq "onchange") {
	$eventNode = $eventsNode.SelectSingleNode("event[@name='$eventName']")
}
else {
	$eventNode = $eventsNode.SelectSingleNode("event[@name='$eventName' and @attribute='$attributeName']")
}

if (-not $eventNode ) {
	$eventNode = $entityXml.CreateElement('event')
	$eventNode.SetAttribute('name', $eventName)
	$eventNode.SetAttribute('application', 'false')
	$eventNode.SetAttribute('active', 'true')
	if ($eventName -eq 'onchange') {
		$eventNode.SetAttribute('attribute', $attributeName)
	}

	$handlersNode = $entityXml.CreateElement('Handlers')

	$eventNode.AppendChild($handlersNode) | Out-Null
	$eventsNode.AppendChild($eventNode) | Out-Null

}

# Create a new handler element
$handlerNode = $entityXml.CreateElement('Handler')
$handlerNode.SetAttribute('library', 'examplelibraryname.js')
$handlerNode.SetAttribute('functionName', 'examplefunctionname')
$handlerNode.SetAttribute('passExecutionContext', 'true')
$handlerNode.SetAttribute('enabled', 'true')
$handlerNode.SetAttribute('handlerUniqueId', '{examplehandleruniqueid}')
$handlerNode.SetAttribute('parameters', '')


$handlersNode = $eventNode.SelectSingleNode('Handlers')
$handlersNode.AppendChild($handlerNode) | Out-Null


$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.NewLineHandling = [System.Xml.NewLineHandling]::None
$settings.OmitXmlDeclaration = $false

$writer = [System.Xml.XmlWriter]::Create($entityXmlPath, $settings)
$entityXml.Save($writer)
$writer.Close()