$folderName  = Split-Path $PWD -Leaf
dotnet new mstest -f net8.0
dotnet add $folderName.csproj package FakeXrmEasy.v9 -v 3.9.4

Remove-Item "Test1.cs" -Recurse -Force
