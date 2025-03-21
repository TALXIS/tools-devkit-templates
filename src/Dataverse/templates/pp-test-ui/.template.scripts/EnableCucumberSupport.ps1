dotnet build

dotnet tool install -g dotnet-script

dotnet-script pp-test-ui/scripts/generate-mock-bindings.csx pp-test-ui/bin/Debug/net8.0/TALXIS.TestKit.Bindings.dll pp-test-ui/obj/MockStepBindings.cs

