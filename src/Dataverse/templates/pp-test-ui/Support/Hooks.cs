using Microsoft.Playwright;
using Reqnroll;

namespace TestProjectName.Support;

[Binding]
public sealed class Hooks
{
    public const string BrowserContextKey = "Playwright.BrowserContext";
    public const string PageKey = "Playwright.Page";

    private static IPlaywright? _playwright;
    private static IBrowser? _browser;

    private readonly ScenarioContext _scenarioContext;

    public Hooks(ScenarioContext scenarioContext)
    {
        _scenarioContext = scenarioContext;
    }

    [BeforeTestRun]
    public static async Task BeforeTestRun()
    {
        // Browser binaries must be installed before running tests.
        // Run `pwsh bin/Debug/net8.0/playwright.ps1 install chromium` or see the README.

        _playwright = await Playwright.CreateAsync();
        _browser = await _playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
        {
            Headless = TestConfiguration.Headless,
            SlowMo = TestConfiguration.SlowMo,
            Args = new[] { "--start-maximized" }
        });
    }

    [BeforeScenario]
    public async Task BeforeScenario()
    {
        if (_browser is null)
        {
            throw new InvalidOperationException("Browser is not initialized. BeforeTestRun must complete first.");
        }

        var contextOptions = new BrowserNewContextOptions
        {
            ViewportSize = null
        };

        if (!string.IsNullOrWhiteSpace(TestConfiguration.StorageStatePath) &&
            File.Exists(TestConfiguration.StorageStatePath))
        {
            contextOptions.StorageStatePath = TestConfiguration.StorageStatePath;
        }

        var browserContext = await _browser.NewContextAsync(contextOptions);
        if (TestConfiguration.TracingEnabled)
        {
            await browserContext.Tracing.StartAsync(new TracingStartOptions
            {
                Screenshots = true,
                Snapshots = true,
                Sources = true
            });
        }

        var page = await browserContext.NewPageAsync();
        page.SetDefaultTimeout(TestConfiguration.Timeout);

        _scenarioContext[BrowserContextKey] = browserContext;
        _scenarioContext[PageKey] = page;
    }

    [AfterScenario(Order = int.MaxValue)]
    public async Task AfterScenario()
    {
        if (TestConfiguration.TracingEnabled &&
            _scenarioContext.TestError is null &&
            _scenarioContext.ContainsKey(BrowserContextKey))
        {
            var context = (IBrowserContext)_scenarioContext[BrowserContextKey];
            await context.Tracing.StopAsync();
        }

        if (_scenarioContext.ContainsKey(BrowserContextKey))
        {
            var context = (IBrowserContext)_scenarioContext[BrowserContextKey];
            await context.CloseAsync();
        }
    }

    [AfterTestRun]
    public static async Task AfterTestRun()
    {
        if (_browser is not null)
        {
            await _browser.CloseAsync();
            _browser = null;
        }

        _playwright?.Dispose();
        _playwright = null;
    }
}
