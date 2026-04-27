using CommandLine;

namespace TALXIS.DevKit.Templates.Builder.Models
{
    public class Options
    {
        [Option('r', "ResultFolderPath", Required = false, HelpText = "Path to the folder where the template will be saved.")]
        public string? ResultFolderPath { get; set; }

        [Option('n', "TemplateName", Required = false, HelpText = "Name of the template.")]
        public string? TemplateName { get; set; }

        [Option('i', "TemplateIdentity", Required = false, HelpText = "Identity of the template.")]
        public string? TemplateIdentity { get; set; }

        [Option('s', "TemplateShortName", Required = false, HelpText = "Short name of the template.")]
        public string? TemplateShortName { get; set; }

        [Option('x', "PathToTheImputXmlFile", Required = true, HelpText = "Path to the file that describes the custom control.")]
        public string PathToTheImputXmlFile { get; set; } = string.Empty;
    }
}
