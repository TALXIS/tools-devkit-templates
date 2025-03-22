dotnet build

dotnet tool install -g dotnet-script

dotnet-script scripts/generate-mock-bindings.csx bin/Debug/net8.0/TALXIS.TestKit.Bindings.dll obj/MockStepBindings.cs

