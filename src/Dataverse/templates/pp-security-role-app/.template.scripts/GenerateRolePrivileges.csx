#r "System.Text.Json"
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.RegularExpressions;


var json = "jsonarraystringwhithrolesids";

List<string> guids = new List<string>(
            json
                .Trim('[', ']')                    
                .Split(',', StringSplitOptions.RemoveEmptyEntries) 
        );

for (int i = 0; i < guids.Count; i++)
{
    guids[i] = guids[i].Trim();
}

var filePath = ".\\.template.scripts\\appaccess.xml";

Directory.CreateDirectory(Path.GetDirectoryName(filePath));

using (var writer = new StreamWriter(filePath))
{
    foreach (var permission in guids)
    {
        writer.WriteLine($"<Role id=\"{permission}\" />");
    }
}
