$filePath = ".template.temp\customaction.xml"

$icon16Path = "__image-16x16__"
$icon32Path = "__image-32x32__"

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
    Replace-ButtonIcon -FilePath $filePath -replaseString "__icon-16x16-placeholder__" -iconPath ""
} else {
    $path16 = 'Image16by16="$webresource:' + $icon16Path + '"'
    Replace-ButtonIcon -FilePath $filePath -replaseString "__icon-16x16-placeholder__" -iconPath $path16
}

if ($icon32Path -eq "icon32pathdefault") {
    Replace-ButtonIcon -FilePath $filePath -replaseString "__icon-32x32-placeholder__" -iconPath ""
} else {
    $path32 = 'Image32by32="$webresource:' + $icon32Path + '"'
    Replace-ButtonIcon -FilePath $filePath -replaseString "__icon-32x32-placeholder__" -iconPath $path32
}


