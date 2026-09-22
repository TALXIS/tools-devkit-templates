// Custom code for this connector - implements Microsoft's "Script : ScriptBase" contract.
// Docs: https://learn.microsoft.com/en-us/connectors/custom-connectors/write-code
//
// A few things worth knowing before you write this:
// - Only ONE script file is supported per connector - branch on this.Context.OperationId
//   below if different operations need different handling.
// - Runs on .NET Standard 2.0 with a LIMITED set of namespaces available (see the doc above
//   for the full list) - notably System.Net.Http, System.Text.RegularExpressions,
//   Newtonsoft.Json(.Linq), and Microsoft.Extensions.Logging. Anything outside that list
//   won't compile when the connector is deployed, even if it compiles locally.
// - Execution must finish within 2 minutes; the compiled script can't exceed 1 MB.
// - Always call this.Context.SendAsync(...) to reach the backend - never HttpClient directly.

using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

public class Script : ScriptBase
{
    public override async Task<HttpResponseMessage> ExecuteAsync()
    {
        // Example: inject something the caller should never have to supply themselves -
        // an API key, a required User-Agent, etc. - before forwarding the request.
        // this.Context.Request.Headers.Add("User-Agent", "MyConnector/1.0 (contact@example.com)");

        var response = await this.Context.SendAsync(this.Context.Request, this.CancellationToken)
            .ConfigureAwait(false);

        if (response.IsSuccessStatusCode)
        {
            // Example: reshape/flatten the backend's JSON response before returning it to the
            // caller, so the connector's own OpenAPI response schema stays simple to consume.
            // var body = JObject.Parse(await response.Content.ReadAsStringAsync().ConfigureAwait(false));
            // response.Content = CreateJsonContent(body["someNestedField"].ToString());
        }

        return response;
    }
}
