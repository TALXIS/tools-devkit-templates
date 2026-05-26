using Microsoft.Extensions.Configuration;

namespace TestProjectName.Support;

public static class TestConfiguration
{
    private static readonly IConfigurationRoot Configuration = new ConfigurationBuilder()
        .SetBasePath(AppContext.BaseDirectory)
        .AddJsonFile("appsettings.json", optional: false)
        .AddEnvironmentVariables()
        .Build();

    public static string EnvironmentUrl => GetString("EnvironmentUrl", "TXC_ENVIRONMENT_URL")
        ?? throw new InvalidOperationException("EnvironmentUrl is required. Set 'TestSettings:EnvironmentUrl' in appsettings.json or the 'TXC_ENVIRONMENT_URL' environment variable.");

    public static string AppName => GetString("AppName", "TXC_APP_NAME")
        ?? throw new InvalidOperationException("AppName is required. Set 'TestSettings:AppName' in appsettings.json or the 'TXC_APP_NAME' environment variable.");

    public static bool Headless => GetBool("Headless", "TXC_HEADLESS", defaultValue: false);

    public static int SlowMo => GetInt("SlowMo", "TXC_SLOWMO", defaultValue: 0);

    public static int Timeout => GetInt("Timeout", "TXC_TIMEOUT", defaultValue: 30000);

    public static string StorageStatePath => GetString("StorageStatePath", "TXC_STORAGE_STATE_PATH") ?? string.Empty;

    public static bool ScreenshotOnFailure => GetBool("ScreenshotOnFailure", "TXC_SCREENSHOT_ON_FAILURE", defaultValue: true);

    public static bool TracingEnabled => GetBool("TracingEnabled", "TXC_TRACING_ENABLED", defaultValue: false);

    public static string OutputPath => GetString("OutputPath", "TXC_OUTPUT_PATH") ?? "TestResults";

    private static string? GetString(string settingName, string environmentVariableName)
    {
        return Environment.GetEnvironmentVariable(environmentVariableName)
            ?? Configuration[$"TestSettings:{settingName}"];
    }

    private static bool GetBool(string settingName, string environmentVariableName, bool defaultValue)
    {
        var value = GetString(settingName, environmentVariableName);
        return bool.TryParse(value, out var parsed) ? parsed : defaultValue;
    }

    private static int GetInt(string settingName, string environmentVariableName, int defaultValue)
    {
        var value = GetString(settingName, environmentVariableName);
        return int.TryParse(value, out var parsed) ? parsed : defaultValue;
    }
}
