$proc = Start-Process dotnet -ArgumentList "run --file .template.scripts/AddFilteringAttributes.cs" -NoNewWindow -Wait -PassThru -RedirectStandardOutput ".template.scripts/script_output.txt" -RedirectStandardError ".template.scripts/script_error.txt"
if ($proc.ExitCode -ne 0) {
    $errorContent = Get-Content ".template.scripts/script_error.txt" -Raw -ErrorAction SilentlyContinue
    Write-Error "AddFilteringAttributes.cs failed (exit code $($proc.ExitCode)). Error: $errorContent"
    exit 1
}