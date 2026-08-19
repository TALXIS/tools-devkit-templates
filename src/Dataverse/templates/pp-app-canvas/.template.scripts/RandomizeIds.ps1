$ErrorActionPreference = 'Stop'

# Regenerate the paired Id / FileID GUIDs inside the .msapp ZIP's
# Properties.json. Everything else (identity.json GUIDs + Test_* hex key +
# numeric suffix + logical name) is handled by template-engine generators.

$baseDir = "__solution-root-path__/CanvasApps"

Add-Type -AssemblyName System.IO.Compression           | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

$msapp = Get-ChildItem -Path $baseDir -Filter '*_DocumentUri.msapp' -File | Select-Object -First 1
if (-not $msapp) { return }

$zip = [System.IO.Compression.ZipFile]::Open($msapp.FullName, 'Update')
try {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq 'Properties.json' } | Select-Object -First 1
    if (-not $entry) { return }

    $reader  = New-Object System.IO.StreamReader($entry.Open())
    $content = $reader.ReadToEnd()
    $reader.Close()

    $newGuid = [guid]::NewGuid().ToString()
    $content = $content -replace '"Id"\s*:\s*"[^"]+"',     ('"Id": "'     + $newGuid + '"')
    $content = $content -replace '"FileID"\s*:\s*"[^"]+"', ('"FileID": "' + $newGuid + '"')

    $entry.Delete()
    $newEntry = $zip.CreateEntry('Properties.json')
    $writer = New-Object System.IO.StreamWriter($newEntry.Open())
    try {
        $writer.Write($content)
    } finally {
        $writer.Close()
    }
} finally {
    $zip.Dispose()
}
