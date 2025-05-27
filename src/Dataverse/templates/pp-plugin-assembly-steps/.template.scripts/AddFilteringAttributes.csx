#r "Newtonsoft.Json"
using Newtonsoft.Json;
using System.Xml;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.RegularExpressions;

string examplePublisher = "examplepublisher";
var json = "jsonarraystringwhithentitiesList";
string xmlPath = ".template.temp/{pluginstepexampleid}.xml";
string PluginProjectName = "examplepluginprojectname"; 
string cleanPluginProjectName = PluginProjectName.Replace(".", ""); 

string cleanedString = json
    .Trim('{', '}')                    
    .Replace(" ", "")
    .Replace("\"", "");                 

string[] entities = cleanedString.Split(',', StringSplitOptions.RemoveEmptyEntries);

var jsonObject = new { entities = entities };

string entitiesList = JsonConvert.SerializeObject(jsonObject, Newtonsoft.Json.Formatting.Indented);

dynamic entityData = JsonConvert.DeserializeObject(entitiesList);

var attributes = new List<string>();
foreach (string entity in entityData.entities)
{
    attributes.Add($"{examplePublisher}_{entity.Trim()}");
}

XmlDocument doc = new XmlDocument();
doc.Load(xmlPath);

XmlNode filteringNode = doc.SelectSingleNode("//FilteringAttributes");
if (filteringNode != null)
{
    filteringNode.InnerText = string.Join(",", attributes);

}

doc.Save(xmlPath);
string xmlContent = File.ReadAllText(xmlPath);
xmlContent = xmlContent.Replace("buildnameexample", cleanPluginProjectName);
File.WriteAllText(xmlPath, xmlContent);

