#r "nuget: System.Text.Json, 8.0.2"
#r "nuget: System.Reflection.MetadataLoadContext, 8.0.0"

using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.Json;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

//  CONFIG 
var dllPath = Args.Count > 0 ? Args[0] : throw new Exception(" DLL path not provided");
var outputPath = Args.Count > 1 ? Args[1] : "FakeStepBindings.cs";

if (!File.Exists(dllPath))
{
    return;
}

// LOAD DLL AND EXTRACT STEP DEFINITIONS
var assembly = Assembly.LoadFrom(dllPath);
var stepAttributes = new[] { "GivenAttribute", "WhenAttribute", "ThenAttribute" };

var steps = new HashSet<Step>();

foreach (var type in assembly.GetTypes())
{
    foreach (var method in type.GetMethods())
    {
        foreach (var attr in method.GetCustomAttributes())
        {
            var attrType = attr.GetType();
            if (stepAttributes.Contains(attrType.Name))
            {
                var prop = attrType.GetProperty("Regex") ?? attrType.GetProperty("Pattern") ?? attrType.GetProperty("Text");
                var text = prop?.GetValue(attr)?.ToString();

                if (!string.IsNullOrWhiteSpace(text))
                {
                    steps.Add(
                        new Step(
                            attrType.Name.Replace("Attribute", ""),
                            text,
                            method.Name
                        )
                    );
                }
            }
        }
    }
}

// GENERATE FAKE .cs FILE
var sb = new StringBuilder();
sb.AppendLine("using Reqnroll;");
sb.AppendLine("namespace FakeBindingsForEditor");
sb.AppendLine("{");
sb.AppendLine("    public class FakeStepBindings");
sb.AppendLine("    {");

foreach (var step in steps)
{
    var simplifiedText = step.Text.Replace("\"", "\\\"");
    sb.AppendLine($"        [{step.StepType}(\"{simplifiedText}\")] ");
    sb.AppendLine($"        public void {step.Method}() {{ }}");
    sb.AppendLine();
}

sb.AppendLine("    }");
sb.AppendLine("}");

// CREATE DIRECTORY AND WRITE FILE 
var fullPath = Path.GetFullPath(outputPath);
var dir = Path.GetDirectoryName(fullPath);
if (!string.IsNullOrWhiteSpace(dir))
{
    Directory.CreateDirectory(dir);
}

File.WriteAllText(fullPath, sb.ToString());

// STEP CLASS DEFINITION
public class Step
{
    public string StepType {get; set;}
    public string Text {get; set;}
    public string Method {get; set;}

    public Step(string stepType, string text, string method)
    {
        StepType = stepType;
        Text = text;
        Method = method;
    }
}
