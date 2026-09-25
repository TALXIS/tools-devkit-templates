using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization.Metadata;
using System.Text.RegularExpressions;


// Raw string literal: the substituted value may legally contain double quotes
// (e.g. [{"privilegetype":"Read","level":"Global"}]). A normal literal would
// terminate early and break the build.
var json = """
jsonarraystringwhithPrivilegeTypeandandLevel
""";

// Allow the terser unquoted form [{privilegetype: Read, level: Global}] by
// quoting bare keys and values. Already-quoted JSON is left untouched.
string fixedJson = Regex.Replace(json, @"(\w+):\s*(\w+)", "\"$1\": \"$2\"");

List<Dictionary<string, string>>? permissions;
try
{
    permissions = JsonSerializer.Deserialize<List<Dictionary<string, string>>>(fixedJson, new JsonSerializerOptions
    {
        PropertyNameCaseInsensitive = true,
        AllowTrailingCommas = true,
        TypeInfoResolver = new DefaultJsonTypeInfoResolver()
    });
}
catch (JsonException ex)
{
    Console.Error.WriteLine($"PrivilegeTypeAndLevel is not valid JSON: {ex.Message}");
    Console.Error.WriteLine($"Received: {json}");
    return 1;
}

if (permissions is null || permissions.Count == 0)
{
    Console.Error.WriteLine("PrivilegeTypeAndLevel did not contain any privileges.");
    Console.Error.WriteLine($"Received: {json}");
    return 1;
}

// Dataverse privilege names are prvCreate<entity>, prvRead<entity>, ...
var knownTypes = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
{
    ["Create"] = "Create",
    ["Read"] = "Read",
    ["Write"] = "Write",
    ["Delete"] = "Delete",
    ["Append"] = "Append",
    ["AppendTo"] = "AppendTo",
    ["Assign"] = "Assign",
    ["Share"] = "Share",
};

// The role XSD enumerates Basic/Local/Deep/Global. Accept the friendlier
// Dataverse UI wording too so documented examples work as written.
var knownLevels = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
{
    ["None"] = "None",
    ["Basic"] = "Basic",
    ["User"] = "Basic",
    ["Local"] = "Local",
    ["BusinessUnit"] = "Local",
    ["Deep"] = "Deep",
    ["ParentChild"] = "Deep",
    ["Global"] = "Global",
};

string scriptsDir = Path.GetFileName(Directory.GetCurrentDirectory()) == ".template.scripts"
    ? Directory.GetCurrentDirectory()
    : Path.Combine(Directory.GetCurrentDirectory(), ".template.scripts");
Directory.CreateDirectory(scriptsDir);
var filePath = Path.Combine(scriptsDir, "privileges.xml");

var lines = new List<string>();
for (int i = 0; i < permissions.Count; i++)
{
    var permission = permissions[i];

    var rawType = Lookup(permission, "privilegetype", "type");
    var rawLevel = Lookup(permission, "level");

    if (string.IsNullOrWhiteSpace(rawType))
    {
        Console.Error.WriteLine($"Privilege at position {i + 1} has no 'privilegetype'. Expected one of: {string.Join(", ", knownTypes.Values)}.");
        return 1;
    }

    if (string.IsNullOrWhiteSpace(rawLevel))
    {
        Console.Error.WriteLine($"Privilege '{rawType}' has no 'level'. Expected one of: None, Basic, Local, Deep, Global.");
        return 1;
    }

    if (!knownTypes.TryGetValue(rawType, out var privilegeType))
    {
        Console.Error.WriteLine($"Unknown privilege type '{rawType}'. Expected one of: {string.Join(", ", knownTypes.Values)}.");
        return 1;
    }

    if (!knownLevels.TryGetValue(rawLevel, out var level))
    {
        Console.Error.WriteLine($"Unknown privilege level '{rawLevel}'. Expected one of: None, Basic, Local, Deep, Global.");
        return 1;
    }

    if (level == "None")
    {
        // Absence of the privilege is how "no access" is expressed.
        continue;
    }

    lines.Add($"<RolePrivilege name=\"prv{privilegeType}entityexamplename\" level=\"{level}\" />");
}

File.WriteAllLines(filePath, lines);
return 0;

static string? Lookup(Dictionary<string, string> permission, params string[] keys)
{
    foreach (var key in keys)
    {
        foreach (var pair in permission)
        {
            if (string.Equals(pair.Key, key, StringComparison.OrdinalIgnoreCase))
            {
                return pair.Value;
            }
        }
    }

    return null;
}
