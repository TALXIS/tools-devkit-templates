$entityXmlPath = ./.template.scripts/LocateForm.ps1

[xml]$entityXml = Get-Content -Path $entityXmlPath -Raw

$eventsNode = $entityXml.SelectSingleNode('//events')
if (-not $eventsNode) {
	$entityXml.SelectSingleNode('//form').AppendChild($entityXml.CreateElement('events')) | Out-Null
	$eventsNode = $entityXml.SelectSingleNode('//events')
}

$eventName = 'exampleeventname'
$attributeName = 'exampleattributename'

# onchange belongs to a field and onclick to a button control: both events are
# keyed by that id in attribute="...", as in every built-in dialog. onload and
# onsave belong to the form and have no attribute.
$isControlEvent = $eventName -in @('onchange', 'onclick')
if ($isControlEvent -and ([string]::IsNullOrWhiteSpace($attributeName) -or $attributeName -eq ('example' + 'attributename'))) {
	Write-Error "AttributeName is required for $eventName events: pass the field logical name (onchange) or the button control id (onclick)."
	exit 1
}

# Reuse the existing event for the same form event or the same field/control
if ($isControlEvent) {
	$eventNode = $eventsNode.SelectSingleNode("event[@name='$eventName' and @attribute='$attributeName']")
}
else {
	$eventNode = $eventsNode.SelectSingleNode("event[@name='$eventName']")
}

if (-not $eventNode ) {
	$eventNode = $entityXml.CreateElement('event')
	$eventNode.SetAttribute('name', $eventName)
	$eventNode.SetAttribute('application', 'false')
	$eventNode.SetAttribute('active', 'true')
	if ($isControlEvent) {
		$eventNode.SetAttribute('attribute', $attributeName)
	}

	$handlersNode = $entityXml.CreateElement('Handlers')

	$eventNode.AppendChild($handlersNode) | Out-Null
	$eventsNode.AppendChild($eventNode) | Out-Null

}

# Create a new handler element
$handlerNode = $entityXml.CreateElement('Handler')
$handlerNode.SetAttribute('libraryName', '$webresource:examplelibraryname.js')
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