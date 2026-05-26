using Microsoft.Playwright;
using Reqnroll;

namespace TestProjectName.Support.Bindings;

[Binding]
public sealed class TabSectionSteps
{
    private readonly ScenarioContext _scenarioContext;
    private IPage Page => (IPage)_scenarioContext[Hooks.PageKey];

    public TabSectionSteps(ScenarioContext scenarioContext)
    {
        _scenarioContext = scenarioContext;
    }

    [When("I open the {string} tab")]
    public async Task WhenIOpenTheTab(string tabLabel)
    {
        await Page.GetByRole(AriaRole.Tab, new PageGetByRoleOptions { Name = tabLabel }).ClickAsync();
    }

    [When("I collapse the {string} section")]
    public async Task WhenICollapseTheSection(string sectionLabel)
    {
        await ToggleSectionAsync(sectionLabel, expand: false);
    }

    [When("I expand the {string} section")]
    public async Task WhenIExpandTheSection(string sectionLabel)
    {
        await ToggleSectionAsync(sectionLabel, expand: true);
    }

    [Then("the {string} tab should be visible")]
    public async Task ThenTheTabShouldBeVisible(string tabLabel)
    {
        var tab = Page.GetByRole(AriaRole.Tab, new PageGetByRoleOptions { Name = tabLabel });
        Assert.IsTrue(await tab.IsVisibleAsync(), $"Tab '{tabLabel}' was expected to be visible.");
    }

    [Then("the {string} tab should be hidden")]
    public async Task ThenTheTabShouldBeHidden(string tabLabel)
    {
        var tab = Page.GetByRole(AriaRole.Tab, new PageGetByRoleOptions { Name = tabLabel });
        Assert.IsFalse(await tab.IsVisibleAsync(), $"Tab '{tabLabel}' was expected to be hidden.");
    }

    private async Task ToggleSectionAsync(string sectionLabel, bool expand)
    {
        var section = Page.GetByRole(AriaRole.Group, new PageGetByRoleOptions { Name = sectionLabel });
        var toggle = section.Locator("button, [role='button']").First;

        var expandedAttribute = await toggle.GetAttributeAsync("aria-expanded");
        var isExpanded = string.Equals(expandedAttribute, "true", StringComparison.OrdinalIgnoreCase);

        if (isExpanded != expand)
        {
            await toggle.ClickAsync();
        }
    }
}
