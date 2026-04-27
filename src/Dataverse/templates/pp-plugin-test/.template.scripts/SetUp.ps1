$folderName  = Split-Path $PWD -Leaf
dotnet new mstest -f net462
dotnet add $folderName.csproj package FakeXrmEasy.v9 -v 2.8.0
dotnet add $folderName.csproj package Microsoft.CrmSdk.CoreAssemblies -v 9.0.2.52

Remove-Item "Test1.cs" -Recurse -Force