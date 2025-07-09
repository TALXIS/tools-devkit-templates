$targetDir = "SolutionDeclarationsRoot\Workflows"  

$guid = [guid]::NewGuid().ToString()
$guidUpper = $guid.ToUpperInvariant()
$guidLower = $guid.ToLowerInvariant()
$guidNoDashes = $guid -replace '-', ''

$files = Get-ChildItem -Path $targetDir -Recurse -File | Where-Object {
    (Get-Content $_.FullName -Raw) -match 'exampleworkflowuniqueidcapital|exampleworkflowuniqueid' -or
    $_.Name -like '*exampleworkflowuniqueidcapital*'
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    $content = $content -replace 'exampleworkflowuniqueidcapital', $guidUpper

    $content = $content -replace 'exampleworkflowuniqueid', $guidLower

    $content = $content -replace '_exampleworkflowNoDashesid_', $guidNoDashes

    Set-Content -Path $file.FullName -Value $content
}

$filesToRename = Get-ChildItem -Path $targetDir -Recurse -File | Where-Object { $_.Name -like '*exampleworkflowuniqueidcapital*' }
foreach ($file in $filesToRename) {
    $newName = $file.Name -replace 'exampleworkflowuniqueidcapital', $guidUpper
    $newPath = Join-Path $file.DirectoryName $newName
    Rename-Item -Path $file.FullName -NewName $newName
}


$filePath = ".template.scripts\WorkflowsID.txt"

Set-Content -Path $filePath -Value $guid