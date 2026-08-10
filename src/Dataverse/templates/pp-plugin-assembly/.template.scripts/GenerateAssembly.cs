using System;
using System.Diagnostics;
using System.IO;
using System.Xml;
using System.Linq;
using System.Reflection;
using System.Text.Json;
using System.Collections.Generic;

string pluginRootPath = @"__plugin-project-root__";
string pluginAssemblyId = "__assembly-id__";
string outputRoot = Path.GetFileName(Directory.GetCurrentDirectory()) == ".template.scripts"
    ? Path.GetFullPath("..")
    : Directory.GetCurrentDirectory();
string resolvedPluginRootPath = Path.IsPathRooted(pluginRootPath)
    ? Path.GetFullPath(pluginRootPath)
    : Path.GetFullPath(Path.Combine(outputRoot, pluginRootPath));


string csprojPath = Directory.GetFiles(resolvedPluginRootPath, "*.csproj").FirstOrDefault();
if (csprojPath == null) throw new Exception("csproj not found");
string projectDirectory = Path.GetDirectoryName(csprojPath);
string csprojFileName = Path.GetFileNameWithoutExtension(csprojPath);

// Load the csproj early for the few static properties that are safe to read as literal XML
// (AssemblyName / FileVersion are not subject to SDK-default fallback logic the way
// TargetFramework and the output path are).
XmlDocument csprojDoc = new XmlDocument();
csprojDoc.Load(csprojPath);
string assemblyName = csprojDoc.SelectNodes("//Project/PropertyGroup/AssemblyName").Cast<XmlNode>().LastOrDefault()?.InnerText ?? csprojFileName;
string fileVersion = csprojDoc.SelectNodes("//Project/PropertyGroup/FileVersion").Cast<XmlNode>().LastOrDefault()?.InnerText ?? "1.0.0.0";

// --- Resolve TargetFramework and the real build/publish output directories via MSBuild itself ---
//
// Earlier revisions of this script hardcoded "net462", then (#135) fell back to a hardcoded
// "net472" literal when <TargetFramework> was absent from the csproj — both are re-implementations
// of TALXIS.DevKit.Build.Sdk's own default-resolution logic, and both break silently the moment
// that SDK default changes again. Same problem existed for the output *path*: reconstructing
// bin/<Configuration>/<TargetFramework>/ by string concatenation assumes nobody has customized
// <OutputPath>, <BaseOutputPath>, or <OutDir>.
//
// Instead, ask MSBuild for the actual, fully-resolved values via the .NET SDK's
// `-getProperty` evaluation switch (SDK 8+; this repo's build agents run SDK 9/10).
// Verified empirically (see PR discussion): `dotnet build <csproj> -getProperty:X` against a
// project with no prior bin/obj creates neither directory and does not invoke the Build/
// CoreCompile targets — it is a property-evaluation-only pass, not a real build, and it's
// fast (~0.7-0.9s measured here per invocation). `dotnet msbuild` measured the same. This
// script itself already only runs once per template scaffold invocation (as a post-action,
// after the plugin project has already been built separately), so there's no nested-build/
// node-reuse conflict with an in-flight build of the same project.
static Dictionary<string, string> QueryMSBuildProperties(string csprojPath, params string[] properties)
{
    var psi = new ProcessStartInfo("dotnet")
    {
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        UseShellExecute = false,
        WorkingDirectory = Path.GetDirectoryName(csprojPath),
    };
    psi.ArgumentList.Add("build");
    psi.ArgumentList.Add(csprojPath);
    psi.ArgumentList.Add("-nologo");
    foreach (string property in properties) psi.ArgumentList.Add($"-getProperty:{property}");

    using Process proc = Process.Start(psi) ?? throw new Exception("Failed to start 'dotnet build -getProperty' process.");
    string stdout = proc.StandardOutput.ReadToEnd();
    string stderr = proc.StandardError.ReadToEnd();
    proc.WaitForExit();

    if (proc.ExitCode != 0)
        throw new Exception(
            $"'dotnet build \"{csprojPath}\" -nologo {string.Join(" ", properties.Select(p => $"-getProperty:{p}"))}' " +
            $"failed with exit code {proc.ExitCode} while resolving MSBuild properties.\nSTDOUT:\n{stdout}\nSTDERR:\n{stderr}");

    var result = new Dictionary<string, string>();
    try
    {
        using JsonDocument doc = JsonDocument.Parse(stdout);
        // Multiple -getProperty switches produce {"Properties": {"Name": "Value", ...}}.
        // A single -getProperty prints the bare value with no JSON wrapper at all (handled below).
        if (doc.RootElement.ValueKind == JsonValueKind.Object && doc.RootElement.TryGetProperty("Properties", out JsonElement propsElement))
        {
            foreach (string property in properties)
                result[property] = propsElement.TryGetProperty(property, out JsonElement value) ? value.GetString() ?? "" : "";
            return result;
        }
    }
    catch (JsonException)
    {
        // Fall through to the single-property bare-text case below.
    }

    if (properties.Length == 1)
    {
        result[properties[0]] = stdout.Trim();
        return result;
    }

    throw new Exception($"Could not parse MSBuild -getProperty output for '{csprojPath}'.\nSTDOUT:\n{stdout}\nSTDERR:\n{stderr}");
}

// MSBuild's -getProperty output for path-valued properties can be relative (relative to the
// project directory) and can mix '\' and '/' separators (e.g. "bin\\Debug/net472/publish/",
// because $(OutputPath) is a literal "bin\" combined with a forward-slash-joined TFM segment).
// Normalize separators, then resolve relative to the project directory if not already rooted.
static string ResolveMSBuildPath(string rawValue, string projectDirectory)
{
    if (string.IsNullOrWhiteSpace(rawValue)) return null;
    string normalized = rawValue.Replace('\\', '/');
    return Path.GetFullPath(Path.IsPathRooted(normalized) ? normalized : Path.Combine(projectDirectory, normalized));
}

Dictionary<string, string> msbuildProps = QueryMSBuildProperties(csprojPath, "TargetFramework", "TargetDir", "PublishDir");

string targetFramework = msbuildProps.GetValueOrDefault("TargetFramework");
if (string.IsNullOrWhiteSpace(targetFramework))
    throw new Exception($"MSBuild did not report a TargetFramework for '{csprojPath}'. Raw properties: {string.Join(", ", msbuildProps.Select(kv => $"{kv.Key}={kv.Value}"))}");

// TargetDir is MSBuild's own fully-resolved build output directory (absolute), so it already
// reflects any <OutputPath>/<BaseOutputPath>/<OutDir> customization instead of us guessing it.
string buildDir = ResolveMSBuildPath(msbuildProps.GetValueOrDefault("TargetDir"), projectDirectory);
if (string.IsNullOrWhiteSpace(buildDir))
    throw new Exception($"MSBuild did not report a TargetDir for '{csprojPath}'.");

// PublishDir is likewise MSBuild's own resolved publish output directory. It's normally
// TargetDir + "publish/" but ask for it explicitly rather than assume that convention holds.
string publishDir = ResolveMSBuildPath(msbuildProps.GetValueOrDefault("PublishDir"), projectDirectory);
if (string.IsNullOrWhiteSpace(publishDir)) publishDir = Path.Combine(buildDir, "publish");

// Probe both the plain build output (TargetDir/*.dll) and the published output
// (PublishDir/*.dll). Only a build has necessarily run by the time this script executes (via
// the transitive ProjectReference build), so the publish output may not exist yet. When it
// *does* exist, prefer it: TALXIS.DevKit.Build.Sdk's plugin publish pipeline ILRepack-merges
// the plugin's dependencies into the output assembly, so the published copy is the more
// complete/authoritative one for reflecting over the plugin's types.
static string ResolveExistingPath(string buildDir, string publishDir, string fileName, string description, string projectDirectory, string targetFramework)
{
    string publishPath = Path.Combine(publishDir, fileName);
    string buildPath = Path.Combine(buildDir, fileName);
    if (File.Exists(publishPath)) return publishPath;
    if (File.Exists(buildPath)) return buildPath;
    throw new FileNotFoundException(
        $"Could not find {description} ('{fileName}'). Probed:\n  {buildPath}\n  {publishPath}\n" +
        $"Ensure the plugin project at '{projectDirectory}' has been built (dotnet build/publish) for TargetFramework '{targetFramework}'.",
        buildPath);
}

string sdkPath = ResolveExistingPath(buildDir, publishDir, "Microsoft.Xrm.Sdk.dll", "Microsoft.Xrm.Sdk.dll", projectDirectory, targetFramework);
Assembly.LoadFrom(sdkPath);

string xmlPath = Path.Combine(outputRoot, "__solution-root-path__", "PluginAssemblies", $"{assemblyName}.dll.data.xml");

string dllPath = ResolveExistingPath(buildDir, publishDir, $"{assemblyName}.dll", "plugin assembly", resolvedPluginRootPath, targetFramework);

Assembly pluginAssembly = Assembly.LoadFrom(dllPath);
byte[] token = pluginAssembly.GetName().GetPublicKeyToken();
if (token == null || token.Length == 0) throw new Exception("Build not signed");
string publicKeyToken = BitConverter.ToString(token).Replace("-", "").ToLower();

var classList = pluginAssembly.GetTypes()
    .Where(t => t.IsClass && t.IsPublic && 
        t.GetInterfaces().Any(i => i.FullName == "Microsoft.Xrm.Sdk.IPlugin"))
    .Select(t => t.FullName)
    .ToList();

if (!classList.Any()) throw new Exception("Plugins not found");

Directory.CreateDirectory(Path.GetDirectoryName(xmlPath));

XmlDocument pluginDoc = new XmlDocument();
XmlDeclaration xmlDecl = pluginDoc.CreateXmlDeclaration("1.0", "utf-8", null);
pluginDoc.AppendChild(xmlDecl);

XmlElement root = pluginDoc.CreateElement("PluginAssembly");
root.SetAttribute("FullName", $"{assemblyName}, Version={fileVersion}, Culture=neutral, PublicKeyToken={publicKeyToken}");
root.SetAttribute("PluginAssemblyId", pluginAssemblyId);
root.SetAttribute("CustomizationLevel", "1");
root.SetAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
pluginDoc.AppendChild(root);

XmlElement isolationMode = pluginDoc.CreateElement("IsolationMode");
isolationMode.InnerText = "2";
root.AppendChild(isolationMode);

XmlElement sourceType = pluginDoc.CreateElement("SourceType");
sourceType.InnerText = "0";
root.AppendChild(sourceType);

XmlElement fileName = pluginDoc.CreateElement("FileName");
fileName.InnerText = $"/PluginAssemblies/{assemblyName}.dll";
root.AppendChild(fileName);

XmlElement pluginTypes = pluginDoc.CreateElement("PluginTypes");
root.AppendChild(pluginTypes);

foreach (var className in classList)
{
    if (className == $"{csprojFileName}.PluginBase") continue;

    XmlElement pluginType = pluginDoc.CreateElement("PluginType");
    pluginType.SetAttribute("AssemblyQualifiedName", $"{className}, {assemblyName}, Version={fileVersion}, Culture=neutral, PublicKeyToken={publicKeyToken}");
    pluginType.SetAttribute("PluginTypeId", Guid.NewGuid().ToString("D"));
    pluginType.SetAttribute("Name", className);

    XmlElement friendlyName = pluginDoc.CreateElement("FriendlyName");
    friendlyName.InnerText = Guid.NewGuid().ToString("D");
    pluginType.AppendChild(friendlyName);

    pluginTypes.AppendChild(pluginType);
}

pluginDoc.Save(xmlPath);

XmlDocument solutionDoc = new XmlDocument();
XmlElement solutionRoot = solutionDoc.CreateElement("RootComponent");
solutionRoot.SetAttribute("type", "91");
solutionRoot.SetAttribute("id", $"{{{pluginAssemblyId}}}");
solutionRoot.SetAttribute("schemaName", $"{assemblyName}, Version={fileVersion}, Culture=neutral, PublicKeyToken={publicKeyToken}");
solutionRoot.SetAttribute("behavior", "0");

solutionDoc.AppendChild(solutionRoot);

Directory.CreateDirectory(Path.Combine(outputRoot, ".template.temp"));

solutionDoc.Save(Path.Combine(outputRoot, ".template.temp", "RootComponent.xml"));


