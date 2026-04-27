using System.Globalization;
using System.Text.RegularExpressions;

namespace TALXIS.DevKit.Templates.Builder.Models;

public class TemplateHeaderModel
{
    public string TemplateName { get; }
    public string TemplateIdentity { get; }
    public string TemplateShortName { get; }
    public string CustomControlName {get;}

    public TemplateHeaderModel(Options options, string parsedName, string displayNameKey)
    {
        ArgumentNullException.ThrowIfNull(options);
        ArgumentNullException.ThrowIfNull(parsedName);

        CustomControlName = displayNameKey;
        TemplateName = options.TemplateName ?? GetTemplateName(parsedName);
        TemplateIdentity = options.TemplateIdentity ?? GetTemplateIdentity(options.TemplateName ?? parsedName);
        TemplateShortName = options.TemplateShortName ?? GetTemplateShortName(options.TemplateName ?? parsedName);
    }

    private string GetTemplateName(string basicName)
    {
        return $"Power Platform: {basicName}";
    }

    private string GetTemplateIdentity(string basicName)
    {
        TextInfo textInfo = CultureInfo.InvariantCulture.TextInfo;

        string convertedName = textInfo.ToTitleCase(basicName.ToLower());

        convertedName = Regex.Replace(convertedName, @"[^a-zA-Z0-9]", "");

        return $"TALXIS.DevKit.Templates.Dataverse.UI.Controls.CustomControl.{convertedName}";
    }

    private string GetTemplateShortName(string basicName)
    {
        var convertedName = Regex.Replace(basicName.ToLower(), @"[^a-zA-Z0-9]", "");

        return $"pp-control-custom-{convertedName}";
    }
}
