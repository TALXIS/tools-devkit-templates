using System.Reflection;
using Reqnroll;
using TestProjectName.Support;

namespace TestProjectName.Tests;

[TestClass]
public sealed class BindingPatternTests
{
    [TestMethod]
    public void NavigationSteps_match_the_frozen_vocabulary() =>
        AssertBindingPatterns(
            "NavigationSteps",
            [
                "Given:I am logged in as {string}",
                "Given:I open the {string} app",
                "When:I navigate to {string} > {string}",
                "When:I navigate to {string} > {string} > {string}",
                "When:I switch to the {string} app",
                "When:I search for {string} in global search"
            ]);

    [TestMethod]
    public void FormFieldSteps_match_the_frozen_vocabulary() =>
        AssertBindingPatterns(
            "FormFieldSteps",
            [
                "When:I enter {string} into the {string} {word} attribute",
                "When:I clear the {string} {word} attribute",
                "When:I select {string} in the {string} optionset attribute",
                "When:I search for {string} in the {string} lookup attribute",
                "When:I select the first result in the {string} lookup",
                "Then:the {string} attribute should contain {string}",
                "Then:the {string} attribute should be empty",
                "Then:the {string} attribute should be read-only",
                "Then:the {string} attribute should be required",
                "Then:the {string} attribute should be optional",
                "Then:the {string} attribute should be visible",
                "Then:the {string} attribute should be hidden"
            ]);

    [TestMethod]
    public void CommandBarSteps_match_the_frozen_vocabulary() =>
        AssertBindingPatterns(
            "CommandBarSteps",
            [
                "When:I click {string} on the command bar",
                "When:I save the record",
                "When:I save and close the record",
                "When:I delete the record",
                "Then:the record should be saved successfully",
                "Then:the form should not be dirty"
            ]);

    [TestMethod]
    public void ViewSteps_match_the_frozen_vocabulary() =>
        AssertBindingPatterns(
            "ViewSteps",
            [
                "When:I switch to the {string} view",
                "When:I open the record at row {int}",
                "When:I select the record at row {int}",
                "When:I search for {string} in the grid",
                "When:I sort the grid by {string}",
                "Then:the grid should contain {int} records",
                "Then:the grid should contain a record with {string} equal to {string}"
            ]);

    [TestMethod]
    public void TabSectionSteps_match_the_frozen_vocabulary() =>
        AssertBindingPatterns(
            "TabSectionSteps",
            [
                "When:I open the {string} tab",
                "When:I collapse the {string} section",
                "When:I expand the {string} section",
                "Then:the {string} tab should be visible",
                "Then:the {string} tab should be hidden"
            ]);

    [TestMethod]
    public void Binding_inventory_does_not_contain_duplicate_patterns()
    {
        var allPatterns = GetBindingPatterns()
            .Select(result => result.Pattern)
            .ToList();

        Assert.IsTrue(allPatterns.Count > 0, "No step bindings found.");

        var duplicates = allPatterns
            .GroupBy(pattern => pattern)
            .Where(group => group.Count() > 1)
            .Select(group => group.Key)
            .ToList();

        CollectionAssert.AreEqual(new List<string>(), duplicates);
    }

    private static void AssertBindingPatterns(string className, IReadOnlyCollection<string> expectedPatterns)
    {
        var actualPatterns = GetBindingPatterns()
            .Where(result => result.ClassName == className)
            .Select(result => result.Pattern)
            .ToList();

        Assert.IsTrue(actualPatterns.Count > 0, $"No bindings discovered for {className}.");
        CollectionAssert.AreEquivalent(expectedPatterns.ToList(), actualPatterns);
    }

    private static List<(string ClassName, string Pattern)> GetBindingPatterns()
    {
        var assembly = typeof(Hooks).Assembly;

        return assembly.GetTypes()
            .Where(type => type.GetCustomAttributes(typeof(BindingAttribute), inherit: false).Any())
            .SelectMany(
                type => type.GetMethods(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic)
                    .SelectMany(method => method.GetCustomAttributes(inherit: false)
                        .Select(attribute => TryGetPattern(type, attribute))
                        .Where(pattern => pattern is not null)
                        .Select(pattern => (type.Name, pattern!))))
            .ToList();
    }

    private static string? TryGetPattern(Type bindingType, object attribute)
    {
        var attributeTypeName = attribute.GetType().Name;
        var keyword = attributeTypeName switch
        {
            nameof(GivenAttribute) => "Given",
            nameof(WhenAttribute) => "When",
            nameof(ThenAttribute) => "Then",
            _ => null
        };

        if (keyword is null)
        {
            return null;
        }

        var pattern = attribute.GetType().GetProperty("Regex")?.GetValue(attribute)?.ToString()
            ?? attribute.GetType().GetProperty("Expression")?.GetValue(attribute)?.ToString();

        if (string.IsNullOrWhiteSpace(pattern))
        {
            throw new InvalidOperationException($"Could not read step pattern from {bindingType.Name}.");
        }

        return $"{keyword}:{pattern}";
    }
}
