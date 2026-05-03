$targetDir = "SolutionDeclarationsRoot/Workflows"

$guid = [guid]::NewGuid().ToString()
$guidUpper = $guid.ToUpperInvariant()
$guidLower = $guid.ToLowerInvariant()

$files = Get-ChildItem -Path $targetDir -Recurse -File | Where-Object {
    (Get-Content $_.FullName -Raw) -match 'EXAMPLEFLOWWORKFLOWID|exampleflowworkflowid' -or
    $_.Name -like '*EXAMPLEFLOWWORKFLOWID*'
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace 'EXAMPLEFLOWWORKFLOWID', $guidUpper
    $content = $content -replace 'exampleflowworkflowid', $guidLower
    Set-Content -Path $file.FullName -Value $content -NoNewline
}

$filesToRename = Get-ChildItem -Path $targetDir -Recurse -File | Where-Object { $_.Name -like '*EXAMPLEFLOWWORKFLOWID*' }
foreach ($file in $filesToRename) {
    $newName = $file.Name -replace 'EXAMPLEFLOWWORKFLOWID', $guidUpper
    Rename-Item -Path $file.FullName -NewName $newName
}

$filePath = ".template.scripts/FlowWorkflowID.txt"
Set-Content -Path $filePath -Value $guid -NoNewline
