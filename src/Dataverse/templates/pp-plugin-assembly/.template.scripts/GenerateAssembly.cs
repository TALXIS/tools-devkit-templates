using System;
using System.IO;
using System.Xml;
using System.Linq;
using System.Reflection;
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

// Load the csproj early so we can resolve the *actual* TargetFramework the plugin project
// builds with. The scaffolded csproj no longer hardcodes <TargetFramework>net462</TargetFramework>
// (removed in #125) — projects now fall through to TALXIS.DevKit.Build.Sdk's own default,
// which is net472. Hardcoding "net462" here caused builds targeting net472 (the current
// default) to fail with a confusing FileNotFoundException. Read it from the csproj instead,
// defaulting to net472 (the SDK's real fallback) rather than net462 if it's absent.
XmlDocument csprojDoc = new XmlDocument();
csprojDoc.Load(csprojPath);
string assemblyName = csprojDoc.SelectNodes("//Project/PropertyGroup/AssemblyName").Cast<XmlNode>().LastOrDefault()?.InnerText ?? csprojFileName;
string fileVersion = csprojDoc.SelectNodes("//Project/PropertyGroup/FileVersion").Cast<XmlNode>().LastOrDefault()?.InnerText ?? "1.0.0.0";

const string defaultTargetFramework = "net472";
string targetFramework = csprojDoc.SelectNodes("//Project/PropertyGroup/TargetFramework").Cast<XmlNode>().LastOrDefault()?.InnerText;
if (string.IsNullOrWhiteSpace(targetFramework))
{
    // Plugin projects are single-TFM in practice, but be defensive: if only <TargetFrameworks>
    // (plural, multi-target) is present, pick the first entry rather than crashing.
    string targetFrameworks = csprojDoc.SelectNodes("//Project/PropertyGroup/TargetFrameworks").Cast<XmlNode>().LastOrDefault()?.InnerText;
    targetFramework = targetFrameworks?.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).FirstOrDefault();
}
if (string.IsNullOrWhiteSpace(targetFramework)) targetFramework = defaultTargetFramework;

// Probe both a plain `dotnet build` output (bin/Debug/<tfm>/*.dll) and a published output
// (bin/Debug/<tfm>/publish/*.dll). Only a build has necessarily run by the time this script
// executes (via the transitive ProjectReference build), so publish/ may not exist yet.
// When publish/ *does* exist, prefer it: TALXIS.DevKit.Build.Sdk's plugin publish pipeline
// ILRepack-merges the plugin's dependencies into the output assembly, so the published copy
// is the more complete/authoritative one for reflecting over the plugin's types.
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

string buildDir = Path.Combine(projectDirectory, "bin", "Debug", targetFramework);
string publishDirForSdk = Path.Combine(buildDir, "publish");
string sdkPath = ResolveExistingPath(buildDir, publishDirForSdk, "Microsoft.Xrm.Sdk.dll", "Microsoft.Xrm.Sdk.dll", projectDirectory, targetFramework);
Assembly.LoadFrom(sdkPath);

string xmlPath = Path.Combine(outputRoot, "__solution-root-path__", "PluginAssemblies", $"{assemblyName}.dll.data.xml");

string pluginBuildDir = Path.Combine(resolvedPluginRootPath, "bin", "Debug", targetFramework);
string pluginPublishDir = Path.Combine(pluginBuildDir, "publish");
string dllPath = ResolveExistingPath(pluginBuildDir, pluginPublishDir, $"{assemblyName}.dll", "plugin assembly", resolvedPluginRootPath, targetFramework);

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


