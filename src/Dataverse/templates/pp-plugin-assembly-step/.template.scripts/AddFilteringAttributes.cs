using System.Xml;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.RegularExpressions;

var json = "__filtering-attributes__";
string outputRoot = Path.GetFileName(Directory.GetCurrentDirectory()) == ".template.scripts"
    ? Path.GetFullPath("..")
    : Directory.GetCurrentDirectory();
string xmlPath = Path.Combine(outputRoot, ".template.temp", "__step-id__.xml");

string cleanedString = json
    .Trim('{', '}')                    
    .Replace(" ", "")
    .Replace("\"", "");                 

string[] entities = cleanedString.Split(',', StringSplitOptions.RemoveEmptyEntries);

var attributes = new List<string>();
foreach (string entity in entities)
{
    attributes.Add(entity.Trim());
}

XmlDocument doc = new XmlDocument();
doc.Load(xmlPath);

XmlNode filteringNode = doc.SelectSingleNode("//FilteringAttributes");
if (filteringNode != null)
{
    filteringNode.InnerText = string.Join(",", attributes);

}

doc.Save(xmlPath);

