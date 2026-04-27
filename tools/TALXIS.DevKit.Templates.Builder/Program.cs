using CommandLine;
using TALXIS.DevKit.Templates.Builder.Builders;
using TALXIS.DevKit.Templates.Builder.Models;

public class TALXISCustomControlsTemplatesGenerator
{
    static void Main(string[] args)
    {
        Options parsedOptions = null;

        Parser.Default.ParseArguments<Options>(args)
            .WithParsed(o => parsedOptions = o);

        if (parsedOptions != null)
        {
            var templateBuilder = new TemplateBuilder(parsedOptions);

            templateBuilder.Build();
        }
    }
}