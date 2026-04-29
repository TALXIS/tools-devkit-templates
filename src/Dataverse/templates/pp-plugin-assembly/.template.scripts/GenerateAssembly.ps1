$proc = Start-Process dotnet-script -ArgumentList ".template.scripts/GenerateAssembly.csx" -NoNewWindow -Wait -PassThru -RedirectStandardOutput ".template.scripts/script_output.txt" -RedirectStandardError ".template.scripts/script_error.txt"
if ($proc.ExitCode -ne 0) {
    $errorContent = Get-Content ".template.scripts/script_error.txt" -Raw -ErrorAction SilentlyContinue
    Write-Error "GenerateAssembly.csx failed (exit code $($proc.ExitCode)). Ensure the plugin project is built (dotnet publish) and signed. Error: $errorContent"
    exit 1
}