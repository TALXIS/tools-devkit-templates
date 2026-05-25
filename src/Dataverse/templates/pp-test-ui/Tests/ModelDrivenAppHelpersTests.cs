using System.Text.Json;
using Microsoft.Playwright;
using Moq;
using TestProjectName.Support;

namespace TestProjectName.Tests;

[TestClass]
public sealed class ModelDrivenAppHelpersTests
{
    [TestMethod]
    public async Task GetEntityNameAsync_uses_the_expected_script()
    {
        var page = new Mock<IPage>();
        string? capturedScript = null;

        page.Setup(instance => instance.EvaluateAsync<string>(It.IsAny<string>(), It.IsAny<object?>()))
            .Callback<string, object?>((script, _) => capturedScript = script)
            .ReturnsAsync("account");

        var entityName = await ModelDrivenAppHelpers.GetEntityNameAsync(page.Object);

        Assert.AreEqual("account", entityName);
        Assert.AreEqual(ModelDrivenAppHelpers.BuildGetEntityNameScript(), capturedScript);
    }

    [TestMethod]
    public async Task GetFormTypeAsync_uses_the_expected_script()
    {
        var page = new Mock<IPage>();
        string? capturedScript = null;

        page.Setup(instance => instance.EvaluateAsync<int>(It.IsAny<string>(), It.IsAny<object?>()))
            .Callback<string, object?>((script, _) => capturedScript = script)
            .ReturnsAsync(2);

        var formType = await ModelDrivenAppHelpers.GetFormTypeAsync(page.Object);

        Assert.AreEqual(2, formType);
        Assert.AreEqual(ModelDrivenAppHelpers.BuildGetFormTypeScript(), capturedScript);
    }

    [TestMethod]
    public async Task GetAttributeValueAsync_uses_the_expected_script()
    {
        var expected = JsonDocument.Parse("\"Widget A\"").RootElement;
        var page = new Mock<IPage>();
        string? capturedScript = null;

        page.Setup(instance => instance.EvaluateAsync<JsonElement?>(It.IsAny<string>(), It.IsAny<object?>()))
            .Callback<string, object?>((script, _) => capturedScript = script)
            .ReturnsAsync(expected);

        var actual = await ModelDrivenAppHelpers.GetAttributeValueAsync(page.Object, "name");

        Assert.AreEqual("Widget A", actual?.GetString());
        Assert.AreEqual(ModelDrivenAppHelpers.BuildGetAttributeValueScript(), capturedScript);
    }

    [TestMethod]
    public async Task SetAttributeValueAsync_uses_the_expected_script()
    {
        var page = new Mock<IPage>();
        string? capturedScript = null;

        page.Setup(instance => instance.EvaluateAsync<bool>(It.IsAny<string>(), It.IsAny<object?>()))
            .Callback<string, object?>((script, _) => capturedScript = script)
            .ReturnsAsync(true);

        await ModelDrivenAppHelpers.SetAttributeValueAsync(page.Object, "name", "Widget Z");

        Assert.AreEqual(ModelDrivenAppHelpers.BuildSetAttributeValueScript(), capturedScript);
    }

    [TestMethod]
    public async Task GetAllAttributeNamesAsync_uses_the_expected_script()
    {
        var page = new Mock<IPage>();
        string? capturedScript = null;

        page.Setup(instance => instance.EvaluateAsync<List<string>>(It.IsAny<string>(), It.IsAny<object?>()))
            .Callback<string, object?>((script, _) => capturedScript = script)
            .ReturnsAsync(new List<string> { "name", "quantity" });

        var names = await ModelDrivenAppHelpers.GetAllAttributeNamesAsync(page.Object);

        CollectionAssert.AreEqual(new List<string> { "name", "quantity" }, names);
        Assert.AreEqual(ModelDrivenAppHelpers.BuildGetAllAttributeNamesScript(), capturedScript);
    }

    [TestMethod]
    public async Task WaitForFormReadyAsync_uses_the_expected_scripts()
    {
        var page = new Mock<IPage>();
        var dialog = new Mock<ILocator>();
        string? waitForFunctionScript = null;
        string? evaluateScript = null;
        PageWaitForFunctionOptions? waitOptions = null;
        var evaluateInvocationCount = 0;

        page.Setup(instance => instance.WaitForFunctionAsync(It.IsAny<string>(), It.IsAny<object?>(), It.IsAny<PageWaitForFunctionOptions?>()))
            .Callback<string, object?, PageWaitForFunctionOptions?>((script, _, options) =>
            {
                waitForFunctionScript = script;
                waitOptions = options;
            })
            .ReturnsAsync(Mock.Of<IJSHandle>());

        page.Setup(instance => instance.GetByRole(AriaRole.Dialog, It.IsAny<PageGetByRoleOptions?>()))
            .Returns(dialog.Object);

        dialog.Setup(instance => instance.WaitForAsync(It.IsAny<LocatorWaitForOptions?>()))
            .ThrowsAsync(new TimeoutException());

        page.Setup(instance => instance.EvaluateAsync<bool>(It.IsAny<string>(), It.IsAny<object?>()))
            .Callback<string, object?>((script, _) => evaluateScript = script)
            .ReturnsAsync(() =>
            {
                evaluateInvocationCount++;
                return evaluateInvocationCount > 1;
            });

        await ModelDrivenAppHelpers.WaitForFormReadyAsync(page.Object, entityTimeoutMs: 1234, attributeBindMs: 600);

        Assert.AreEqual(ModelDrivenAppHelpers.BuildEntityReadyScript(), waitForFunctionScript);
        Assert.AreEqual(1234f, waitOptions?.Timeout);
        Assert.AreEqual(ModelDrivenAppHelpers.BuildBoundAttributeCheckScript(), evaluateScript);
    }
}
