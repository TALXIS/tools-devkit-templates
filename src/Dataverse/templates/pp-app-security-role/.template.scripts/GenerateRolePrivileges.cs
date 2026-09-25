using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.RegularExpressions;


// Raw string literal: the substituted value may contain quotes or braces.
var json = """
jsonarraystringwhithrolesids
""";

List<string> guids = new List<string>(
            json
                .Trim()
                .Trim('[', ']')
                .Split(',', StringSplitOptions.RemoveEmptyEntries)
        );

string scriptsDir = Path.GetFileName(Directory.GetCurrentDirectory()) == ".template.scripts"
    ? Directory.GetCurrentDirectory()
    : Path.Combine(Directory.GetCurrentDirectory(), ".template.scripts");
Directory.CreateDirectory(scriptsDir);
var filePath = Path.Combine(scriptsDir, "appaccess.xml");

var lines = new List<string>();
foreach (var raw in guids)
{
    // Accept "guid", "{guid}", and quoted variants; emit the braced form the
    // solution XML uses everywhere else.
    var candidate = raw.Trim().Trim('"', '\'').Trim();

    if (candidate.Length == 0)
    {
        continue;
    }

    if (!Guid.TryParse(candidate, out var roleId))
    {
        Console.Error.WriteLine($"'{candidate}' is not a valid security role GUID.");
        Console.Error.WriteLine("SecurityRolesIds expects a comma-separated list of role GUIDs.");
        return 1;
    }

    lines.Add($"<Role id=\"{roleId:B}\" />");
}

if (lines.Count == 0)
{
    Console.Error.WriteLine("SecurityRolesIds did not contain any security role GUIDs.");
    Console.Error.WriteLine($"Received: {json}");
    return 1;
}

File.WriteAllLines(filePath, lines);
return 0;
