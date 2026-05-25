using System.Text.Json;
using Microsoft.Playwright;
using Reqnroll;

namespace TestProjectName.Support.Bindings;

[Binding]
public sealed class FormFieldSteps
{
    private readonly ScenarioContext _scenarioContext;
    private IPage Page => (IPage)_scenarioContext[Hooks.PageKey];

    public FormFieldSteps(ScenarioContext scenarioContext)
    {
        _scenarioContext = scenarioContext;
    }

    [When("I enter {string} into the {string} {word} attribute")]
    public async Task WhenIEnterIntoTheAttribute(string value, string attributeName, string type)
    {
        _ = type;

        var input = await GetFieldInputAsync(attributeName);
        await input.FillAsync(value);
        await ModelDrivenAppHelpers.SetAttributeValueAsync(Page, attributeName, value);
    }

    [When("I clear the {string} {word} attribute")]
    public async Task WhenIClearTheAttribute(string attributeName, string type)
    {
        _ = type;

        var input = await GetFieldInputAsync(attributeName);
        await input.FillAsync(string.Empty);
        await ModelDrivenAppHelpers.SetAttributeValueAsync(Page, attributeName, string.Empty);
    }

    [When("I select {string} in the {string} optionset attribute")]
    public async Task WhenISelectInTheOptionsetAttribute(string optionLabel, string attributeName)
    {
        var field = GetFieldLocator(attributeName);
        var dropdown = field.Locator("[role='combobox'], button[aria-haspopup='listbox']").First;

        await dropdown.ClickAsync();
        await Page.GetByRole(AriaRole.Option, new PageGetByRoleOptions { Name = optionLabel }).ClickAsync();
    }

    [When("I search for {string} in the {string} lookup attribute")]
    public async Task WhenISearchForInTheLookupAttribute(string text, string attributeName)
    {
        var field = GetFieldLocator(attributeName);
        await field.ClickAsync();

        var searchInput = field.Locator("input").First;
        await searchInput.FillAsync(text);
    }

    [When("I select the first result in the {string} lookup")]
    public async Task WhenISelectTheFirstResultInTheLookup(string attributeName)
    {
        var result = Page.Locator("[role='listbox'] [role='option'], [role='grid'] [role='row'], [role='menu'] [role='menuitem']")
            .First;

        await result.ClickAsync();
        await ModelDrivenAppHelpers.WaitForFormReadyAsync(Page);
        _scenarioContext["LastLookupAttribute"] = attributeName;
    }

    [Then("the {string} attribute should contain {string}")]
    public async Task ThenTheAttributeShouldContain(string attributeName, string expectedValue)
    {
        var value = await ModelDrivenAppHelpers.GetAttributeValueAsync(Page, attributeName);
        Assert.AreEqual(expectedValue, ConvertAttributeValueToString(value), $"Attribute '{attributeName}' did not match.");
    }

    [Then("the {string} attribute should be empty")]
    public async Task ThenTheAttributeShouldBeEmpty(string attributeName)
    {
        var value = await ModelDrivenAppHelpers.GetAttributeValueAsync(Page, attributeName);
        Assert.AreEqual(string.Empty, ConvertAttributeValueToString(value), $"Attribute '{attributeName}' was expected to be empty.");
    }

    [Then("the {string} attribute should be read-only")]
    public async Task ThenTheAttributeShouldBeReadOnly(string attributeName)
    {
        var isReadOnly = await Page.EvaluateAsync<bool>(
            "({ attributeName }) => !!window.Xrm?.Page?.getControl?.(attributeName)?.getDisabled?.()",
            new { attributeName });

        Assert.IsTrue(isReadOnly, $"Attribute '{attributeName}' was expected to be read-only.");
    }

    [Then("the {string} attribute should be required")]
    public async Task ThenTheAttributeShouldBeRequired(string attributeName)
    {
        var requiredLevel = await Page.EvaluateAsync<string>(
            "({ attributeName }) => window.Xrm?.Page?.getAttribute?.(attributeName)?.getRequiredLevel?.() ?? ''",
            new { attributeName });

        Assert.AreEqual("required", requiredLevel, $"Attribute '{attributeName}' was expected to be required.");
    }

    [Then("the {string} attribute should be optional")]
    public async Task ThenTheAttributeShouldBeOptional(string attributeName)
    {
        var requiredLevel = await Page.EvaluateAsync<string>(
            "({ attributeName }) => window.Xrm?.Page?.getAttribute?.(attributeName)?.getRequiredLevel?.() ?? ''",
            new { attributeName });

        Assert.AreEqual("none", requiredLevel, $"Attribute '{attributeName}' was expected to be optional.");
    }

    [Then("the {string} attribute should be visible")]
    public async Task ThenTheAttributeShouldBeVisible(string attributeName)
    {
        var isVisible = await Page.EvaluateAsync<bool>(
            "({ attributeName }) => !!window.Xrm?.Page?.getControl?.(attributeName)?.getVisible?.()",
            new { attributeName });

        Assert.IsTrue(isVisible, $"Attribute '{attributeName}' was expected to be visible.");
    }

    [Then("the {string} attribute should be hidden")]
    public async Task ThenTheAttributeShouldBeHidden(string attributeName)
    {
        var isVisible = await Page.EvaluateAsync<bool>(
            "({ attributeName }) => !!window.Xrm?.Page?.getControl?.(attributeName)?.getVisible?.()",
            new { attributeName });

        Assert.IsFalse(isVisible, $"Attribute '{attributeName}' was expected to be hidden.");
    }

    private async Task<ILocator> GetFieldInputAsync(string attributeName)
    {
        var field = GetFieldLocator(attributeName);
        var input = field.Locator("input, textarea, [contenteditable='true']").First;

        await input.WaitForAsync(new LocatorWaitForOptions
        {
            State = WaitForSelectorState.Visible,
            Timeout = TestConfiguration.Timeout
        });

        return input;
    }

    private ILocator GetFieldLocator(string attributeName) =>
        Page.Locator($"[data-field-name=\"{attributeName}\"]").First;

    private static string ConvertAttributeValueToString(JsonElement? value)
    {
        if (value is null)
        {
            return string.Empty;
        }

        return ConvertElementToString(value.Value);
    }

    private static string ConvertElementToString(JsonElement element)
    {
        return element.ValueKind switch
        {
            JsonValueKind.String => element.GetString() ?? string.Empty,
            JsonValueKind.Number => element.GetRawText(),
            JsonValueKind.True => bool.TrueString,
            JsonValueKind.False => bool.FalseString,
            JsonValueKind.Array => string.Join(", ", element.EnumerateArray().Select(ConvertElementToString)),
            JsonValueKind.Null => string.Empty,
            JsonValueKind.Undefined => string.Empty,
            _ => element.ToString()
        };
    }
}
