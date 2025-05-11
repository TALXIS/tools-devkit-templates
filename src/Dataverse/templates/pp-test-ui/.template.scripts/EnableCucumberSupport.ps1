Start-Process dotnet -ArgumentList "build" -NoNewWindow -Wait -RedirectStandardOutput ".template.scripts/build_output.txt" -RedirectStandardError ".template.scripts/build_error.txt"
Start-Sleep -Seconds 10
Start-Process dotnet -ArgumentList "tool install -g dotnet-script" -NoNewWindow -Wait -RedirectStandardOutput ".template.scripts/tool_output.txt" -RedirectStandardError ".template.scripts/tool_error.txt"
Start-Sleep -Seconds 10
Start-Process dotnet-script -ArgumentList "scripts/generate-mock-bindings.csx bin/Debug/net8.0/TALXIS.TestKit.Bindings.dll obj/MockStepBindings.cs" -NoNewWindow -Wait -RedirectStandardOutput ".template.scripts/script_output.txt" -RedirectStandardError ".template.scripts/script_error.txt"