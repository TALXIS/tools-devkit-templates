using System.Text.Json;
using Microsoft.Playwright;

namespace TestProjectName.Support;

public static class ModelDrivenAppHelpers
{
    internal static string BuildGetEntityNameScript() =>
        "() => window.Xrm?.Page?.data?.entity?.getEntityName?.() ?? ''";

    internal static string BuildGetFormTypeScript() =>
        "() => window.Xrm?.Page?.ui?.getFormType?.() ?? 0";

    internal static string BuildGetAttributeValueScript() =>
        "({ attributeName }) => {" +
        " const attribute = window.Xrm?.Page?.data?.entity?.attributes?.get(attributeName);" +
        " return attribute ? attribute.getValue() : null;" +
        "}";

    internal static string BuildSetAttributeValueScript() =>
        "({ attributeName, value }) => {" +
        " const attribute = window.Xrm?.Page?.data?.entity?.attributes?.get(attributeName);" +
        " if (!attribute) { return false; }" +
        " attribute.setValue(value);" +
        " attribute.fireOnChange();" +
        " return true;" +
        "}";

    internal static string BuildEntityReadyScript() =>
        "() => {" +
        " const entity = window.Xrm?.Page?.data?.entity;" +
        " const entityName = entity?.getEntityName?.();" +
        " return typeof entityName === 'string' && entityName.length > 0;" +
        "}";

    internal static string BuildBoundAttributeCheckScript() =>
        "() => {" +
        " const entity = window.Xrm?.Page?.data?.entity;" +
        " if (!entity?.attributes?.forEach) { return false; }" +
        " let count = 0;" +
        " entity.attributes.forEach(() => count++);" +
        " return count > 0;" +
        "}";

    internal static string BuildGetAllAttributeNamesScript() =>
        "() => {" +
        " const names = [];" +
        " const entity = window.Xrm?.Page?.data?.entity;" +
        " if (!entity?.attributes?.forEach) { return names; }" +
        " entity.attributes.forEach(attribute => names.push(attribute.getName()));" +
        " return names;" +
        "}";

    public static async Task<string> GetEntityNameAsync(IPage page)
    {
        return await page.EvaluateAsync<string>(BuildGetEntityNameScript());
    }

    public static async Task<int> GetFormTypeAsync(IPage page)
    {
        return await page.EvaluateAsync<int>(BuildGetFormTypeScript());
    }

    public static async Task<JsonElement?> GetAttributeValueAsync(IPage page, string attributeName)
    {
        return await page.EvaluateAsync<JsonElement?>(BuildGetAttributeValueScript(), new { attributeName });
    }

    public static async Task SetAttributeValueAsync(IPage page, string attributeName, object value)
    {
        var success = await page.EvaluateAsync<bool>(BuildSetAttributeValueScript(), new { attributeName, value });
        if (!success)
        {
            throw new InvalidOperationException(
                $"Attribute '{attributeName}' was not found on the current form. Verify the attribute exists and the form is fully loaded.");
        }
    }

    public static async Task WaitForFormReadyAsync(IPage page, int entityTimeoutMs = 30000, int attributeBindMs = 10000)
    {
        await page.WaitForFunctionAsync(
            BuildEntityReadyScript(),
            null,
            new PageWaitForFunctionOptions { Timeout = entityTimeoutMs });

        var signInDialog = page.GetByRole(AriaRole.Dialog, new PageGetByRoleOptions { Name = "Sign in to continue" });
        try
        {
            await signInDialog.WaitForAsync(new LocatorWaitForOptions
            {
                State = WaitForSelectorState.Visible,
                Timeout = 300
            });

            await signInDialog
                .GetByRole(AriaRole.Button, new LocatorGetByRoleOptions { Name = "Close" })
                .ClickAsync(new LocatorClickOptions { Timeout = 1000 });

            await Task.Delay(1000);
        }
        catch (TimeoutException)
        {
        }

        var deadline = DateTime.UtcNow.AddMilliseconds(attributeBindMs);
        while (DateTime.UtcNow <= deadline)
        {
            if (await page.EvaluateAsync<bool>(BuildBoundAttributeCheckScript()))
            {
                return;
            }

            if (DateTime.UtcNow >= deadline)
            {
                break;
            }

            await Task.Delay(500);
        }

        throw new TimeoutException(
            $"Form attributes were not bound within {attributeBindMs} ms. The entity was resolved but no attributes appeared.");
    }

    public static async Task<List<string>> GetAllAttributeNamesAsync(IPage page)
    {
        return await page.EvaluateAsync<List<string>>(BuildGetAllAttributeNamesScript()) ?? new List<string>();
    }
}
