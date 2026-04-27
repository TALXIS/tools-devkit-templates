$entitiesRootPath = './SolutionDeclarationsRoot/Entities'
$dialogsRootPath = './SolutionDeclarationsRoot/Dialogs'
$formId = "{formguididexample}"

if ( ('formtypeexample' -eq 'unknown') -and ('exampleentityname' -eq 'unknown') -and ('formguididexample' -eq 'unknownFormId') ) {
    $targetDirs = Get-ChildItem -Path $entitiesRootPath -Recurse -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in 'main', 'quickCreate' -and $_.Parent -and $_.Parent.Name -eq 'FormXml' }

    #Entities
    $files = foreach ($dir in $targetDirs) {
        Get-ChildItem -Path $dir.FullName -File -Filter '*.xml' -ErrorAction SilentlyContinue
    }

    #Dialogs
    $files += Get-ChildItem -Path $dialogsRootPath -File -Filter '*.xml' -ErrorAction SilentlyContinue

    if (-not $files) { throw "No XML files under '$entitiesRootPath' in FormXml\main or FormXml\quickCreate." }

    $latest = $files |
    Sort-Object @{ Expression = {
            if ($_.LastWriteTime -gt $_.CreationTime) { $_.LastWriteTime } else { $_.CreationTime }
        }; 
        Descending = $true 
    } |
    Select-Object -First 1

    $entityXmlPath = $latest.FullName
}
elseif ( ('formtypeexample' -eq 'unknown') -or ('exampleentityname' -eq 'unknown') ) {
    $targetName = if ([IO.Path]::GetExtension($formId) -ieq ".xml") { "$formId" } else { "$formId.xml" }

    #Entities
    $matches = Get-ChildItem -Path $entitiesRootPath -Recurse -File -Filter $targetName -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Directory -ne $null -and
        $_.Directory.Name -in @('main', 'quickCreate') -and
        $_.Directory.Parent -ne $null -and
        $_.Directory.Parent.Name -eq 'FormXml'
    }

    #Dialogs
    $matches += Get-ChildItem -Path $dialogsRootPath -Filter "*.xml"

    if (-not $matches) { throw "File '$targetName' not found under '$entitiesRootPath' in FormXml\main or FormXml\quickCreate." }
    if ($matches.Count -gt 1) {
        $matches | ForEach-Object { Write-Host " - $($_.FullName)" }
    }
    $entityXmlPath = $matches[0].FullName
}
elseif ($formId -eq "{unknownFormId}") {
    $formDirectory = './SolutionDeclarationsRoot/Entities/exampleentityname/FormXml/formtypeexample/'

    #Entities
    $collectedForms = Get-ChildItem -Path $formDirectory -Filter "*.xml"
    #Dialogs
    $collectedForms += Get-ChildItem -Path $dialogsRootPath -Filter "*.xml"

    $latestForm = $collectedForms | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($latestForm) {
        $entityXmlPath = $latestForm.FullName
    }
    else {
        Write-Error "No XML forms found in directory: $formDirectory"

        exit 1
    }
}
else {
    if('formtypeexample' -eq 'dialog') 
    {
        $entityXmlPath = (Resolve-Path './SolutionDeclarationsRoot/Dialogs/{formguididexample}.xml').Path
    }
    else {
        $entityXmlPath = (Resolve-Path './SolutionDeclarationsRoot/Entities/exampleentityname/FormXml/formtypeexample/{formguididexample}.xml').Path
    }
}

if (-not $entityXmlPath) {
    Write-Error "No XML forms found"

    exit 1
}

return $entityXmlPath