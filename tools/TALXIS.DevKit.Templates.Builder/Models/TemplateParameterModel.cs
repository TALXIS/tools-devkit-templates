using System.Text.RegularExpressions;
using System.Text.Json;
using System.Linq;

namespace TALXIS.DevKit.Templates.Builder.Models;

public class TemplateParameterModel
{
    // This fields are used to generate the node
    private readonly string _parameterNodeName;
    private readonly string _parameterNodeType;

    // This fields are used to generate the symbol
    private readonly string _parameterName;
    private readonly string _parameterReplacesAttribute;
    private readonly string _parameterIsRequired;
    private readonly string _parameterDescription;
    private readonly ICollection<EnumValuesModel> _parameterEnumValues;

    public string Node
    {
        get
        {
            return $"<{_parameterNodeName} type=\"{_parameterNodeType}\" static=\"true\">{_parameterReplacesAttribute}</{_parameterNodeName}>";
        }
    }

    public TemplateParameterModel(string parameterName, string parameterIsRequired, string parameterDescription, string parameterNodeName, string parameterNodeType, ICollection<EnumValuesModel> parameterEnumValues = null)
    {
        ArgumentNullException.ThrowIfNull(parameterName);
        ArgumentNullException.ThrowIfNull(parameterIsRequired);
        ArgumentNullException.ThrowIfNull(parameterDescription);
        ArgumentNullException.ThrowIfNull(parameterNodeName);
        ArgumentNullException.ThrowIfNull(parameterNodeType);

        _parameterName = Regex.Replace(parameterName, @"[^a-zA-Z0-9]", "");
        _parameterReplacesAttribute = Regex.Replace($"{parameterNodeName}exampletype{parameterNodeType}", @"[^a-zA-Z0-9]", "").ToLower();
        _parameterIsRequired = parameterIsRequired;
        _parameterDescription = parameterDescription;
        _parameterNodeName = parameterNodeName;
        _parameterNodeType = parameterNodeType;
        _parameterEnumValues = parameterEnumValues;
    }

    public static Dictionary<string, object> GenerateSymbolsCollection(ICollection<TemplateParameterModel> parameters)
    {
        ArgumentNullException.ThrowIfNull(parameters);

        var symbolsObject = new Dictionary<string, object>();

        foreach (var param in parameters)
        {

            switch (param._parameterNodeType)
            {
                case "Enum":
                    GenerateEnumSymbols(param, symbolsObject);
                    break;
                case "Object": throw new Exception("Object type is not supported");
                default:
                    GenerateGenericSymbols(param, symbolsObject);
                    break;
            }

        }

        return symbolsObject;
    }

    private static void GenerateEnumSymbols(TemplateParameterModel param, Dictionary<string, object> symbolsObject)
    {
        var combinedDescription = string.Join("; ", param._parameterEnumValues
            .Where(enumValue => !string.IsNullOrEmpty(enumValue.EnumValueDescription))
            .Select(enumValue => $"{enumValue.EnumValueName}: {enumValue.EnumValueDescription}"));


        var choiceSymbol = new Dictionary<string, object>
        {
            ["type"] = "parameter",
            ["datatype"] = "choice",
            ["choices"] = param._parameterEnumValues.Select(enumValue => new Dictionary<string, object>
            {
                ["choice"] = enumValue.EnumValueName
            }).ToArray(),
            ["description"] = $"{param._parameterDescription} ({combinedDescription})"
        };

        if (param._parameterIsRequired == "true")
        {
            choiceSymbol["isRequired"] = true;
        }

        symbolsObject[$"CustomControl_{param._parameterName}"] = choiceSymbol;


        var generatedSymbolName = $"{param._parameterName.ToLower()}value";
        var cases = param._parameterEnumValues.Select(enumValue => new Dictionary<string, object>
        {
            ["condition"] = $"({param._parameterName} == \"{enumValue.EnumValueName}\")",
            ["value"] = enumValue.EnumValue
        }).ToArray();

        var generatedSymbol = new Dictionary<string, object>
        {
            ["type"] = "generated",
            ["generator"] = "switch",
            ["replaces"] = param._parameterReplacesAttribute,
            ["parameters"] = new Dictionary<string, object>
            {
                ["datatype"] = "string",
                ["cases"] = cases
            },
            ["description"] = $"{param._parameterDescription} automatically selected based on {param._parameterName}"
        };

        symbolsObject[generatedSymbolName] = generatedSymbol;
    }

    private static void GenerateGenericSymbols(TemplateParameterModel param, Dictionary<string, object> symbolsObject)
    {
        var symbolObject = new Dictionary<string, object>
        {
            ["type"] = "parameter",
            ["datatype"] = "text",
            ["defaultValue"] = "defaulttemplateexample",
            ["replaces"] = param._parameterReplacesAttribute,
            ["fileRename"] = param._parameterReplacesAttribute,
            ["description"] = param._parameterDescription
        };

        if (param._parameterIsRequired == "true")
        {
            symbolObject["isRequired"] = true;
        }

        symbolsObject[$"CustomControl_{param._parameterName}"] = symbolObject;
    }
}
