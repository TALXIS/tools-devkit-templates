$filePath = "webresourcefilepathexample"
$dataXmlFilePath = "__solution-root-path__/WebResources\examplepublisher_fileexamplename.data.xml"
$destinationFolder = "__solution-root-path__/WebResources"
#$fileDisplayName = [System.IO.Path]::GetFileName($filePath)
#$fileName = $fileDisplayName -replace '[\p{P}\p{Zs}]', ''
$fileName = [System.IO.Path]::GetFileName($filePath)
$fileDisplayName = $fileName 
$newDataXmlFilePath = "__solution-root-path__/WebResources\examplepublisher_$fileName.data.xml"

$guid = [guid]::NewGuid().ToString()
$guidUpper = $guid.ToUpper()

$content = Get-Content -Path $dataXmlFilePath -Raw

$content = $content -replace "fileexamplename", $fileName
$content = $content -replace "fileexampledisplayname", $fileDisplayName
$content = $content -replace "wridexamplecapital", $guidUpper
$content = $content -replace "wridexample", $guid

Remove-Item -Path $dataXmlFilePath

$content = $content.Replace("`r`n", "`n").Replace("`r", "`n")
[System.IO.File]::WriteAllText($newDataXmlFilePath, $content, [System.Text.UTF8Encoding]::new($false))

$fileNewNoExtName = "examplepublisher_$fileName"
$destinationPath = Join-Path $destinationFolder $fileNewNoExtName

Copy-Item -Path $filePath -Destination $destinationPath

