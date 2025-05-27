#r "Newtonsoft.Json"
using Newtonsoft.Json;

// Input string example
string inputString = "{entity1, entity2,entity3}";

// Clean up the input string
string cleanedString = inputString
    .Trim('{', '}')                    // Remove curly braces
    .Replace(" ", "");                 // Remove spaces

// Split the string into array
string[] entities = cleanedString.Split(',', StringSplitOptions.RemoveEmptyEntries);

// Create object for JSON
var jsonObject = new { entities = entities };

// Convert to JSON
string jsonResult = JsonConvert.SerializeObject(jsonObject, Formatting.Indented);

// Print the result
Console.WriteLine("Original string:");
Console.WriteLine(inputString);
Console.WriteLine("\nConverted to JSON:");
Console.WriteLine(jsonResult); 