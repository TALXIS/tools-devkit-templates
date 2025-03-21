$folderPath = "pp-test-ui\scripts"

if (Test-Path $folderPath) 
{
    Remove-Item -Path $folderPath -Recurse -Force
} 

Remove-Item .template.scripts -Recurse -Force