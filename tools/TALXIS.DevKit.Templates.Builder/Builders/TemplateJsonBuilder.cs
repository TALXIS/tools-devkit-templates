using System.Reflection;
using System.Text.Json;
using TALXIS.DevKit.Templates.Builder.Models;

namespace TALXIS.DevKit.Templates.Builder.Builders;

public class TemplateJsonBuilder
{
    public static string CreateTemplateJson(TemplateHeaderModel header, ICollection<TemplateParameterModel> parameters)
    {
        var templateObject = new Dictionary<string, object>
        {
            ["$schema"] = "http://json.schemastore.org/template",
            ["author"] = "NETWORG",
            ["identity"] = header.TemplateIdentity,
            ["name"] = header.TemplateName,
            ["shortName"] = header.TemplateShortName,
            ["sourceName"] = "examplecustomentityattribute",
            ["preferNameDirectory"] = false,
            ["tags"] = new Dictionary<string, object>
            {
                ["language"] = "XML",
                ["type"] = "item"
            }
        };

        var parameterSymbols = TemplateParameterModel.GenerateSymbolsCollection(parameters);
        var additionalSymbols = LoadSymbolsFromEmbeddedResource();
        
        var combinedSymbols = new Dictionary<string, object>(parameterSymbols);
        if (additionalSymbols != null)
        {
            foreach (var kvp in additionalSymbols)
            {
                combinedSymbols[kvp.Key] = kvp.Value;
            }
        }
        
        templateObject["symbols"] = combinedSymbols;

        var postActions = LoadPostActionsFromEmbeddedResource();

        if (postActions != null)
        {
            templateObject["postActions"] = postActions;
        }

        return JsonSerializer.Serialize(templateObject, new JsonSerializerOptions
        {
            WriteIndented = true
        });
    }

    private static object? LoadPostActionsFromEmbeddedResource()
    {
        try
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = "TALXIS.DevKit.Templates.Builder.TemplateAssets.postActions.json";

            using var stream = assembly.GetManifestResourceStream(resourceName);

            if (stream == null)
            {
                Console.WriteLine($"Warning: Could not find embedded resource '{resourceName}'");
                return null;
            }

            using var reader = new StreamReader(stream);
            var jsonContent = reader.ReadToEnd();

            return JsonSerializer.Deserialize<object>(jsonContent);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Warning: Failed to load postActions from embedded resource: {ex.Message}");
            return null;
        }
    }

    private static Dictionary<string, object>? LoadSymbolsFromEmbeddedResource()
    {
        try
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = "TALXIS.DevKit.Templates.Builder.TemplateAssets.symbols.json";
            
            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream == null)
            {
                Console.WriteLine($"Warning: Could not find embedded resource '{resourceName}'");
                return null;
            }
            
            using var reader = new StreamReader(stream);
            var jsonContent = reader.ReadToEnd();
            
            return JsonSerializer.Deserialize<Dictionary<string, object>>(jsonContent);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Warning: Failed to load symbols from embedded resource: {ex.Message}");
            return null;
        }
    }
}
