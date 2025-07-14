$filePath = ".template.temp\customaction.xml"

$icon16Path = "icon16pathexample"
$icon32Path = "icon32pathexample"

function Replace-ButtonIcon {
    param (
        [string]$FilePath,      
        [string]$replaseString, 
        [string]$iconPath       
    )

    $content = Get-Content -Path $FilePath -Raw
    $content = $content -replace $replaseString, $iconPath
    Set-Content -Path $FilePath -Value $content
}

if ($icon16Path -eq "icon16pathdefault") {
    Replace-ButtonIcon -FilePath $filePath -replaseString "exampleicon16" -iconPath ""
} else {
    $path16 = 'Image16by16="$webresource:' + $icon16Path + '"'
    Replace-ButtonIcon -FilePath $filePath -replaseString "exampleicon16" -iconPath $path16
}

if ($icon32Path -eq "icon32pathdefault") {
    Replace-ButtonIcon -FilePath $filePath -replaseString "exampleicon32" -iconPath ""
} else {
    $path32 = 'Image32by32="$webresource:' + $icon32Path + '"'
    Replace-ButtonIcon -FilePath $filePath -replaseString "exampleicon32" -iconPath $path32
}


