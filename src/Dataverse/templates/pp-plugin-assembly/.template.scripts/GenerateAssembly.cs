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

XmlDocument csprojDoc = new XmlDocument();
csprojDoc.Load(csprojPath);
string assemblyName = csprojDoc.SelectNodes("//Project/PropertyGroup/AssemblyName").Cast<XmlNode>().LastOrDefault()?.InnerText ?? csprojFileName;
string fileVersion = csprojDoc.SelectNodes("//Project/PropertyGroup/FileVersion").Cast<XmlNode>().LastOrDefault()?.InnerText ?? "1.0.0.0";
string xmlPath = Path.Combine(outputRoot, "__solution-root-path__", "PluginAssemblies", $"{assemblyName}.dll.data.xml");

// Any configuration/TFM: newest bin/**/publish/<AssemblyName>.dll wins
string binRoot = Path.Combine(projectDirectory, "bin");
string dllPath = Directory.Exists(binRoot)
    ? Directory.GetFiles(binRoot, $"{assemblyName}.dll", SearchOption.AllDirectories)
        .Where(p => Path.GetFileName(Path.GetDirectoryName(p)) == "publish")
        .OrderByDescending(File.GetLastWriteTimeUtc)
        .FirstOrDefault()
    : null;
if (dllPath == null) throw new FileNotFoundException("Published build not found (run dotnet publish)", Path.Combine(binRoot, "**", "publish", $"{assemblyName}.dll"));

string sdkPath = new[] { Path.GetDirectoryName(dllPath), Path.GetDirectoryName(Path.GetDirectoryName(dllPath)) }
    .Select(dir => Path.Combine(dir, "Microsoft.Xrm.Sdk.dll"))
    .FirstOrDefault(File.Exists);
if (sdkPath != null) Assembly.LoadFrom(sdkPath);

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


