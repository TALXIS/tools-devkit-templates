#r "System.Text.Json"
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.RegularExpressions;


public class Privilege
{
    public string PrivilegeType { get; set; }
    public string Level { get; set; }
}

var json = "jsonarraystringwhithPrivilegeTypeandandLevel";

string fixedJson = Regex.Replace(json, @"(\w+):\s*(\w+)", "\"$1\": \"$2\"");

var permissions = JsonSerializer.Deserialize<List<Privilege>>(fixedJson, new JsonSerializerOptions
{
    PropertyNameCaseInsensitive = true
});

var filePath = ".\\.template.scripts\\privileges.xml";

using (var writer = new StreamWriter(filePath))
{
    foreach (var permission in permissions)
    {
        writer.WriteLine($"<RolePrivilege name=\"prv{permission.PrivilegeType}entityexamplename\" level=\"{permission.Level}\" />");
    }
}
