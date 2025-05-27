$xmlPath = ".template.temp/{pluginstepexampleid}.xml" 
$PluginProjectName = "examplepluginprojectname"
$plaginBuildName = $PluginProjectName.Replace(".", "")
$pluginguidIdExampleToUpper = "pluginguididexample".ToUpper()
$xmlPluginPath = "SolutionDeclarationsRoot\PluginAssemblies/${plaginBuildName}-${pluginguidIdExampleToUpper}/${plaginBuildName}.dll.data.xml"

if (-not (Test-Path $xmlPluginPath)) {
    throw "Plugin file not found in the path: $xmlPluginPath"
}
if (-not (Test-Path $xmlPath)) {
    throw "Plugin file not found in the path: $xmlPath"
}

[xml]$xml = Get-Content $xmlPluginPath

$fullName = $xml.PluginAssembly.FullName
if ($fullName -match "PublicKeyToken=([a-zA-Z0-9]+)") {
    $publicKeyToken = $matches[1]
}
else {
    throw "PublicKeyToken not found in plugin file"
}

$content = Get-Content $xmlPath -Raw
if ($content -match 'PublicKeyToken=publickeytokenexample') {
    $content = $content -replace 'publickeytokenexample', $publicKeyToken
    $content | Set-Content $xmlPath -Force
}

