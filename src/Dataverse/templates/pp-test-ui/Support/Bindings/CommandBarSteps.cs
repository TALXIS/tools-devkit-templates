using Microsoft.Playwright;
using Reqnroll;

namespace TestProjectName.Support.Bindings;

[Binding]
public sealed class CommandBarSteps
{
    private readonly ScenarioContext _scenarioContext;
    private IPage Page => (IPage)_scenarioContext[Hooks.PageKey];

    public CommandBarSteps(ScenarioContext scenarioContext)
    {
        _scenarioContext = scenarioContext;
    }

    [When("I click {string} on the command bar")]
    public async Task WhenIClickOnTheCommandBar(string commandLabel)
    {
        await ClickCommandAsync(commandLabel);
    }

    [When("I save the record")]
    public async Task WhenISaveTheRecord()
    {
        await ClickCommandAsync("Save");
    }

    [When("I save and close the record")]
    public async Task WhenISaveAndCloseTheRecord()
    {
        await ClickCommandAsync("Save & Close");
    }

    [When("I delete the record")]
    public async Task WhenIDeleteTheRecord()
    {
        await ClickCommandAsync("Delete");
    }

    [Then("the record should be saved successfully")]
    public async Task ThenTheRecordShouldBeSavedSuccessfully()
    {
        await Page.WaitForFunctionAsync(
            "() => window.Xrm?.Page?.data?.entity?.getIsDirty?.() === false",
            null,
            new PageWaitForFunctionOptions { Timeout = TestConfiguration.Timeout });

        Assert.IsFalse(await IsFormDirtyAsync(), "The record is still dirty after save.");
    }

    [Then("the form should not be dirty")]
    public async Task ThenTheFormShouldNotBeDirty()
    {
        Assert.IsFalse(await IsFormDirtyAsync(), "The form is still dirty.");
    }

    private async Task ClickCommandAsync(string commandLabel)
    {
        var directButton = Page.Locator($"[data-id=\"CommandBar\"] button[aria-label=\"{commandLabel}\"]").First;
        if (await directButton.CountAsync() > 0 && await directButton.IsVisibleAsync())
        {
            await directButton.ClickAsync();
            return;
        }

        var overflowButton = Page.Locator("[data-id=\"CommandBar\"] button[data-id*=\"OverflowButton\"]").First;
        await overflowButton.ClickAsync();

        var overflowCommand = Page.Locator($"[role=\"menu\"] button[aria-label=\"{commandLabel}\"]").First;
        await overflowCommand.ClickAsync();
    }

    private async Task<bool> IsFormDirtyAsync()
    {
        return await Page.EvaluateAsync<bool>("() => !!window.Xrm?.Page?.data?.entity?.getIsDirty?.()");
    }
}
