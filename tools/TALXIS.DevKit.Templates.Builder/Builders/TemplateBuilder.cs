using System.Reflection;
using TALXIS.DevKit.Templates.Builder.Models;

namespace TALXIS.DevKit.Templates.Builder.Builders
{
    internal class TemplateBuilder
    {
        private readonly Options _options;
        private string _basePath;

        internal TemplateBuilder(Options options)
        {
            _options = options;
        }

        internal void Build()
        {
            try
            {
                ImputXmlParser imputXmlParser = new();

                imputXmlParser.ParseXml(_options);

                SetBasePath(imputXmlParser.Header.TemplateShortName);

                GenerateTemplateDotJson(imputXmlParser);

                GenerateTemplateScripts(imputXmlParser.Header.CustomControlName);

                GenerateTemplateTempFiles(imputXmlParser.Parameters);
            }
            catch (Exception ex)
            {
                Directory.Delete(_basePath, true);

                Console.WriteLine($"Error building template: {ex.Message}");
                throw;
            }

        }

        private void GenerateTemplateDotJson(ImputXmlParser imputXmlParser)
        {
            string templateJson = TemplateJsonBuilder.CreateTemplateJson(imputXmlParser.Header, imputXmlParser.Parameters);

            string templateDotJsonPath = Path.Combine(_basePath, ".template.config", "template.json");

            string directoryPath = Path.GetDirectoryName(templateDotJsonPath);

            Directory.CreateDirectory(directoryPath);

            File.WriteAllText(templateDotJsonPath, templateJson);
        }

        private void GenerateTemplateScripts(string customControlName)
        {
            string scriptsDirectory = Path.Combine(_basePath, ".template.scripts");
            Directory.CreateDirectory(scriptsDirectory);

            CopyTemplateScripts(scriptsDirectory);

            string scriptPath = Path.Combine(scriptsDirectory, "AddCustomControlParameters.ps1");

            string content = File.ReadAllText(scriptPath);
            string modifiedContent = content.Replace("customcontrolnameexample", customControlName);

            File.WriteAllText(scriptPath, modifiedContent);
        }

        private void GenerateTemplateTempFiles(ICollection<TemplateParameterModel> parameters)
        {
            string tempDirectory = Path.Combine(_basePath, ".template.temp");
            Directory.CreateDirectory(tempDirectory);

            string tempFile = Path.Combine(tempDirectory, "customcontrolparameters.xml");

            string xml = GenerateParametersXml(parameters);

            File.WriteAllText(tempFile, xml);
        }

        private string GenerateParametersXml(ICollection<TemplateParameterModel> parameters)
        {
            var xmlBuilder = new System.Text.StringBuilder();
            xmlBuilder.AppendLine("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
            xmlBuilder.AppendLine("<parameters>");

            foreach (var parameter in parameters)
            {
                xmlBuilder.AppendLine($"  {parameter.Node}");
            }

            xmlBuilder.AppendLine("</parameters>");
            
            return xmlBuilder.ToString();
        }

        private void SetBasePath(string templateShortName)
        {
            string basePath = string.IsNullOrEmpty(_options.ResultFolderPath)
                ? Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? Environment.CurrentDirectory
                : _options.ResultFolderPath;

            string templatePath = Path.Combine(basePath, templateShortName);

            string directoryPath = Path.GetDirectoryName(templatePath);

            if (!Directory.Exists(directoryPath))
            {
                Directory.CreateDirectory(directoryPath);
            }

            _basePath = templatePath;
        }

        private void CopyTemplateScripts(string scriptsDirectory)
        {
            try
            {
                var assembly = Assembly.GetExecutingAssembly();
                var resourcePrefix = "TALXIS.DevKit.Templates.Builder.TemplateAssets._template.scripts.";

                var resourceNames = assembly.GetManifestResourceNames();

                if (resourceNames.Length == 0)
                {
                    Console.WriteLine("Warning: No template scripts found in embedded resources");
                    return;
                }

                foreach (var resourceName in resourceNames)
                {
                    var fileName = resourceName.Substring(resourcePrefix.Length);

                    using var stream = assembly.GetManifestResourceStream(resourceName);
                    if (stream == null) continue;

                    string filePath = Path.Combine(scriptsDirectory, fileName);
                    using var fileStream = File.Create(filePath);
                    stream.CopyTo(fileStream);
                }
            }
            catch (Exception ex)
            {
            }
        }
    }
}
