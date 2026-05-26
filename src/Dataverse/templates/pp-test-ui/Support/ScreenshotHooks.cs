using Microsoft.Playwright;
using Reqnroll;

namespace TestProjectName.Support;

[Binding]
public sealed class ScreenshotHooks
{
    private readonly ScenarioContext _scenarioContext;
    private readonly TestContext _testContext;

    public ScreenshotHooks(ScenarioContext scenarioContext, TestContext testContext)
    {
        _scenarioContext = scenarioContext;
        _testContext = testContext;
    }

    [AfterScenario(Order = 0)]
    public async Task CaptureArtifactsOnFailure()
    {
        if (_scenarioContext.TestError is null || !_scenarioContext.ContainsKey(Hooks.PageKey))
        {
            return;
        }

        var outputRoot = Path.Combine(AppContext.BaseDirectory, TestConfiguration.OutputPath);
        Directory.CreateDirectory(outputRoot);

        var sanitizedScenarioTitle = SanitizeFileName(_scenarioContext.ScenarioInfo.Title);
        var page = (IPage)_scenarioContext[Hooks.PageKey];

        if (TestConfiguration.ScreenshotOnFailure)
        {
            var screenshotDirectory = Path.Combine(outputRoot, "screenshots");
            Directory.CreateDirectory(screenshotDirectory);

            var screenshotPath = Path.Combine(screenshotDirectory, $"{sanitizedScenarioTitle}.png");
            await page.ScreenshotAsync(new PageScreenshotOptions
            {
                Path = screenshotPath,
                FullPage = true
            });

            _testContext.AddResultFile(screenshotPath);
            _testContext.WriteLine($"Screenshot: {screenshotPath}");
        }

        if (TestConfiguration.TracingEnabled && _scenarioContext.ContainsKey(Hooks.BrowserContextKey))
        {
            var traceDirectory = Path.Combine(outputRoot, "traces");
            Directory.CreateDirectory(traceDirectory);

            var tracePath = Path.Combine(traceDirectory, $"{sanitizedScenarioTitle}.zip");
            var context = (IBrowserContext)_scenarioContext[Hooks.BrowserContextKey];
            await context.Tracing.StopAsync(new TracingStopOptions { Path = tracePath });

            _testContext.AddResultFile(tracePath);
            _testContext.WriteLine($"Trace: {tracePath}");
        }
    }

    private static string SanitizeFileName(string value)
    {
        var invalidCharacters = Path.GetInvalidFileNameChars();
        return string.Concat(value.Select(character => invalidCharacters.Contains(character) ? '_' : character));
    }
}
