namespace TALXIS.DevKit.Templates.Builder;

public class EnumValuesModel
{
    public string EnumValue { get; }
    public string EnumValueName { get; }
    public string EnumValueDescription { get; }

    public EnumValuesModel(string enumValue, string enumValueName, string enumValueDescription)
    {
        ArgumentNullException.ThrowIfNull(enumValue);
        ArgumentNullException.ThrowIfNull(enumValueName);
        ArgumentNullException.ThrowIfNull(enumValueDescription);

        EnumValue = enumValue;
        EnumValueName = enumValueName;
        EnumValueDescription = enumValueDescription;
    }
}
