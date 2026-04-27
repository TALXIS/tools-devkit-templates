$formId = "{formguididexample}"

if ($formId -eq "unknownFormId") {
    $formDirectory = './SolutionDeclarationsRoot/Dialogs/'

    $latestForm = Get-ChildItem -Path $formDirectory -Filter "*.xml" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($latestForm) {
        $entityXmlPath = $latestForm.FullName
    }
    else {
        Write-Error "No XML forms found in directory: $formDirectory"

        exit 1
    }
}
else {
    $entityXmlPath = (Resolve-Path './SolutionDeclarationsRoot/Dialogs/{formguididexample}.xml').Path
}

if (-not $entityXmlPath) {
    Write-Error "No XML forms found"

    exit 1
}

return $entityXmlPath