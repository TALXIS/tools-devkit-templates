$javaScriptFunctionName = "functioexamplenname"
$commandDefinitionId= "examplepublisher.exampleentityname.Command.functioexamplennamelibraryexamplelogicalname"
$ribbonXmlPath = (Resolve-Path './SolutionDeclarationsRoot/Entities/exampleentityname/RibbonDiff.xml').Path
$parameterXmlPath = (Resolve-Path './.template.temp/parameter.xml').Path

[xml]$ribbonXml = Get-Content $ribbonXmlPath -Raw

[xml]$parameterXml = Get-Content $parameterXmlPath -Raw

$commandDefinition = $ribbonXml.SelectSingleNode("//CommandDefinition[@Id='$commandDefinitionId']")

if (-not $commandDefinition) {
    Write-Error "CommandDefinition with ID '$commandDefinitionId' not found in RibbonDiff.xml"
    exit 1
}

$javaScriptFunction = $commandDefinition.SelectSingleNode(".//JavaScriptFunction[@FunctionName='$javaScriptFunctionName']")

if (-not $javaScriptFunction) {
    Write-Error "JavaScriptFunction with FunctionName '$javaScriptFunctionName' not found in CommandDefinition '$commandDefinitionId'"
    exit 1
}

$parameters = $parameterXml.SelectNodes("//Parameters/*")

if ($parameters.Count -eq 0) {
    Write-Warning "No parameters found in parameter.xml"
    exit 0
}

foreach ($parameter in $parameters) {
    $clonedParameter = $ribbonXml.ImportNode($parameter, $true)
    $javaScriptFunction.AppendChild($clonedParameter) | Out-Null
    Write-Host "Added parameter: $($parameter.Name)"
}

$ribbonXml.Save($ribbonXmlPath)
Write-Host "Successfully updated RibbonDiff.xml with parameters"