using System;
using System.IO;
using System.Xml;
using System.Linq;
using System.Reflection;
using System.Collections.Generic;

string pluginRootPath = @"pluginprojectrootpathexample";
string pluginAssemblyId = "pluginguididexample";


string csprojPath = Directory.GetFiles(pluginRootPath, "*.csproj").FirstOrDefault();
if (csprojPath == null) throw new Exception("csproj не найден");
string projectDirectory = Path.GetDirectoryName(csprojPath);
string sdkPath = @$"{projectDirectory}\bin\Debug\net462\Microsoft.Xrm.Sdk.dll"; 
Assembly.LoadFrom(sdkPath);
string csprojFileName = Path.GetFileNameWithoutExtension(csprojPath);

XmlDocument csprojDoc = new XmlDocument();
csprojDoc.Load(csprojPath);
string assemblyName = csprojDoc.SelectSingleNode("//Project/PropertyGroup/AssemblyName")?.InnerText ?? csprojFileName;
string fileVersion = csprojDoc.SelectSingleNode("//Project/PropertyGroup/FileVersion")?.InnerText ?? "1.0.0.0";
string xmlPath = Path.Combine(Directory.GetCurrentDirectory(), $"SolutionDeclarationsRoot//PluginAssemblies//{assemblyName}-{pluginAssemblyId.ToUpper()}//{assemblyName}.dll.data.xml");

string dllPath = Path.Combine(pluginRootPath, "bin", "Debug", "net462", "publish", $"{assemblyName}.dll");
if (!File.Exists(dllPath)) throw new FileNotFoundException("Сборка не найдена", dllPath);

Assembly pluginAssembly = Assembly.LoadFrom(dllPath);
byte[] token = pluginAssembly.GetName().GetPublicKeyToken();
if (token == null || token.Length == 0) throw new Exception("Сборка не подписана");
string publicKeyToken = BitConverter.ToString(token).Replace("-", "").ToLower();

var classList = pluginAssembly.GetTypes()
    .Where(t => t.IsClass && t.IsPublic && 
        t.GetInterfaces().Any(i => i.FullName == "Microsoft.Xrm.Sdk.IPlugin"))
    .Select(t => t.FullName)
    .ToList();

if (!classList.Any()) throw new Exception("Плагины не найдены");

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
fileName.InnerText = $"/PluginAssemblies/{assemblyName}-{pluginAssemblyId.ToUpper()}/{assemblyName}.dll";
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

File.Copy(dllPath, $"{Path.GetDirectoryName(xmlPath)}\\{assemblyName}.dll");

XmlDocument solutionDoc = new XmlDocument();
XmlElement solutionRoot = solutionDoc.CreateElement("RootComponent");
solutionRoot.SetAttribute("type", "91");
solutionRoot.SetAttribute("id", $"{{{pluginAssemblyId}}}");
solutionRoot.SetAttribute("schemaName", $"{assemblyName}, Version={fileVersion}, Culture=neutral, PublicKeyToken={publicKeyToken}");
solutionRoot.SetAttribute("behavior", "0");

solutionDoc.AppendChild(solutionRoot);

Directory.CreateDirectory(Path.Combine(Directory.GetCurrentDirectory(), ".template.temp"));

solutionDoc.Save(".template.temp\\RootComponent.xml");



