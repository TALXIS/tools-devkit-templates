using System.Xml;
using TALXIS.DevKit.Templates.Builder.Models;

namespace TALXIS.DevKit.Templates.Builder;

public class ImputXmlParser
{
    public TemplateHeaderModel Header { get; private set; }
    public ICollection<TemplateParameterModel> Parameters { get; private set; } = new List<TemplateParameterModel>();

    public void ParseXml(Options options)
    {
        ArgumentNullException.ThrowIfNull(options);
        
        var xmlDoc = LoadXmlDocument(options.PathToTheImputXmlFile);
        
        Header = new TemplateHeaderModel(
            options,
            ParseConstructorFromXml(xmlDoc),
            ParsecontrolDisplayNamekeyFromXml(xmlDoc));

        ParseParametersFromXml(xmlDoc);
    }

    private XmlDocument LoadXmlDocument(string xmlFilePath)
    {
        try
        {
            var xmlDoc = new XmlDocument();

            xmlDoc.Load(xmlFilePath);

            return xmlDoc;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Failed to load XML file '{xmlFilePath}': {ex.Message}", ex);
        }
    }

    private string ParseConstructorFromXml(XmlDocument xmlDoc)
    {
        var controlNode = xmlDoc.SelectSingleNode("//control");

        if (controlNode?.Attributes?["constructor"] != null)
        {
            return controlNode.Attributes["constructor"].Value;
        }

        throw new InvalidOperationException("Constructor attribute not found in control element");
    }

    private string ParsecontrolDisplayNamekeyFromXml(XmlDocument xmlDoc)
    {
        var controlNode = xmlDoc.SelectSingleNode("//control");

        if (controlNode?.Attributes?["display-name-key"] != null)
        {
            return controlNode.Attributes["display-name-key"].Value;
        }

        throw new InvalidOperationException("Display name key attribute not found in control element");
    }

    private void ParseParametersFromXml(XmlDocument xmlDoc)
    {
        var propertyNodes = xmlDoc.SelectNodes("//property");

        if (propertyNodes == null) return;

        foreach (XmlNode propertyNode in propertyNodes)
        {
            var parameter = CreateParameterFromPropertyNode(propertyNode);

            Parameters.Add(parameter);
        }
    }

    private TemplateParameterModel CreateParameterFromPropertyNode(XmlNode propertyNode)
    {
        string parameterNodeType = GetAttributeValue(propertyNode, "of-type");
        
        ICollection<EnumValuesModel> parameterEnumValues = null;

        if (parameterNodeType == "Enum")
        {
            parameterEnumValues = ParseEnumValues(propertyNode);
        }

        var parameter = new TemplateParameterModel(
            GetAttributeValue(propertyNode, "display-name-key"), 
            GetAttributeValue(propertyNode, "required"),         
            GetAttributeValue(propertyNode, "description-key"),  
            GetAttributeValue(propertyNode, "name"),             
            parameterNodeType,          
            parameterEnumValues                                                
        );

        return parameter;
    }

    private ICollection<EnumValuesModel> ParseEnumValues(XmlNode propertyNode)
    {
        var enumValues = new List<EnumValuesModel>();

        var valueNodes = propertyNode.SelectNodes("value");
        if (valueNodes == null) return enumValues;

        foreach (XmlNode valueNode in valueNodes)
        {
            EnumValuesModel enumValue = new(
                valueNode.InnerText,
                GetAttributeValue(valueNode, "display-name-key"),
                GetAttributeValue(valueNode, "description-key")
            );

            enumValues.Add(enumValue);
        }

        return enumValues;
    }

    private string GetAttributeValue(XmlNode node, string attributeName)
    {
        return node?.Attributes?[attributeName]?.Value ?? string.Empty;
    }
}
