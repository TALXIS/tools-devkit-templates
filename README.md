# Power Platform .NET Templates
> [!WARNING]
> This project is currently in a development phase and not ready for production use.
> While we actively use these tools internally, our aim is to share and collaborate with the broader community to refine and enhance their capabilities.
> We are in the process of gradually open-sourcing the code, removing internal dependencies to make it universally applicable.
> At this stage, it serves as a source of inspiration and a basis for collaboration.
> We welcome feedback, suggestions, and contributions through pull requests.

If wish to use this project for your team, please contact us at hello@networg.com for a personalized onboarding experience and customization to meet your specific needs.

> [!CAUTION]
> Only use this if you understand the standard platform customization capabilities.
> Using these templates with parameter combinations other than those documented here might generate invalid source code, which could still be importable to Dataverse.
> In some situations, this could cause your environment to become irreversibly corrupted.

## Goal
The primary objective of this NuGet package is to help Power Platform developers scaffold Power Platform components using a code-first approach.

## Guide
You can refer to a [VS Code snippets file](https://gist.github.com/TomProkop/607a9de00d811a5ae68327e90f6a81cf) used by [@TomProkop](https://github.com/TomProkop) for conference demos.

### Dev machine setup
```powershell
# If you're using .NET CLI for the first time, you might need to set up nuget.org as a package source
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org

# Install PowerShell 7+ to have "pwsh" executable present in your terminal
# To support running the templates cross-platform "pwsh" is used instead of "powershell.exe"
# You can use other installation methods
dotnet tool install --global PowerShell

# Install the template package to your machine
dotnet new install TALXIS.DevKit.Templates.Dataverse
```
## Templates
### Solutions
> [!NOTE]
> Template commands are designed to be run in the folder where *.*proj is located.
> Use --output parameter if your working directory is different.

Initialize a new empty solution:
```console
dotnet new pp-solution `
--output "src/Solutions.DataModel" `
--PublisherName "tomas" `
--PublisherPrefix "tom" `
--allow-scripts yes
```

### Tables
Create a new *standard* table:
```console
dotnet new pp-entity `
--output "src/Solutions.DataModel" `
--Behavior New `
--PublisherPrefix "tom" `
--LogicalName "location" `
--LogicalNamePlural "locations" `
--DisplayName "Location" `
--DisplayNamePlural "Locations" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Create a new *activity* table:
```console
dotnet new pp-entity `
--output "src/Solutions.DataModel" `
--EntityType "Activity" `
--Behavior "New" `
--PublisherPrefix "tom" `
--LogicalName "shiftevent" `
--LogicalNamePlural "shiftevents" `
--DisplayName "Shift Event" `
--DisplayNamePlural "Shift Events" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Create a new *elastic* table:
```console
dotnet new pp-entity `
--output "src/Solutions.DataModel" `
--EntityType "Elastic" `
--Behavior "New" `
--PublisherPrefix "tom" `
--LogicalName "inboundmessage" `
--LogicalNamePlural "inboundmessages" `
--DisplayName "Inbound Message" `
--DisplayNamePlural "Inbound Messages" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Add an existing *custom table* to a solution:
```console
dotnet new pp-entity `
--output "src/Solutions.UI" `
--Behavior "Existing" `
--PublisherPrefix "tom" `
--LogicalName "shiftevent" `
--DisplayName "Shift Event" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Add an existing *system table* to a solution:
```console
dotnet new pp-entity `
--output "src/Solutions.UI" `
--Behavior "Existing" `
--IsSystemEntity "true"  `
--LogicalName "account" `
--DisplayName "Account" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

### Columns
Add a whole number column to table:
```console
dotnet new pp-entity-attribute `
--output "src/Solutions.DataModel" `
--EntitySchemaName "tom_warehouseitem" `
--AttributeType "WholeNumber" `
--RequiredLevel "required" `
--PublisherPrefix "tom" `
--LogicalName "availablequantity" `
--DisplayName "Available Quantity" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Add a lookup column to table:
```console
dotnet new pp-entity-attribute `
--output "src/Solutions.DataModel" `
--EntitySchemaName "tom_warehousetransaction" `
--AttributeType "Lookup" `
--RequiredLevel "required" `
--LogicalName "tom_itemid" `
--DisplayName "Item" `
--ReferencedEntityName "tom_warehouseitem" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Create a global OptionSet:
```console
dotnet new pp-optionset-global `
--output "src/Solutions.DataModel" `
--RequiredLevel "required" `
--LogicalName "${publisherPrefix}_paymentmethod" `
--DisplayName "Payment Method" `
--SolutionRootPath "Declarations" `
--OptionSetOptions "Visa,Mastercard,Cash" `
--allow-scripts yes

Add global OptionSet to the table:
```console
dotnet new pp-entity-attribute `
--output "src/Solutions.DataModel" `
--EntitySchemaName "${publisherPrefix}_warehousetransaction" `
--AttributeType "OptionSet(Global)" `
--RequiredLevel "required" `
--LogicalName "${publisherPrefix}_paymentmethod" `
--DisplayName "Payment Method" `
--GlobalOptionSetType "Existing" `
--SolutionRootPath "Declarations" `
--allow-scripts yes

Create a local OptionSet:
```console
dotnet new pp-entity-attribute `
--output "src/Solutions.DataModel" `
--EntitySchemaName "${publisherPrefix}_warehouseitem" `
--AttributeType "OptionSet(Local)" `
--RequiredLevel "required" `
--LogicalName "${publisherPrefix}_packagetype" `
--DisplayName "Package Type" `
--OptionSetOptions "Box,Bag,Envelope" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

### Environment variables
Add an environment variable definition (plain text with default value):
```console
dotnet new pp-environment-variable-definition `
--output "src/Solutions.Configuration" `
--SolutionRootPath "Declarations" `
--PublisherPrefix "tom" `
--LogicalName "portal_hostnamemain" `
--DisplayName "Portal Hostname (Main)" `
--Description "Primary hostname for the portal frontend." `
--Type "String" `
--DefaultValue "portal.example.com" `
--allow-scripts yes
```

Other supported `--Type` values are `Number`, `Boolean` (`--DefaultValue yes`/`no`), `JSON`, `Secret` (Azure Key Vault — sets `secretstore=1`), and `ConnectionReference` (DataSource). `--Description`, `--DefaultValue` and `--IsRequired` (0/1) are optional. The definition folder is created under `<SolutionRootPath>/environmentvariabledefinitions/<prefix>_<LogicalName>/`, and the definition is registered as `<RootComponent type="380">` in `Other/Solution.xml` (idempotent — re-runs with `--force` don't duplicate).

Add the default value for an existing definition:
```console
dotnet new pp-environment-variable-value `
--output "src/Solutions.Configuration" `
--SolutionRootPath "Declarations" `
--DefinitionLogicalName "tom_portal_hostnamemain" `
--Value "portal.production.example.com" `
--allow-scripts yes
```

The value JSON is written next to `environmentvariabledefinition.xml`. Arbitrary characters in `--Value` (double quotes, backslashes, JSON payloads) are escaped automatically via `ConvertTo-Json`, so JSON-type variables can carry their default object as-is:

```console
dotnet new pp-environment-variable-value `
--output "src/Solutions.Configuration" `
--SolutionRootPath "Declarations" `
--DefinitionLogicalName "tom_auditnotification_configuration" `
--Value '{"account":["name","description"],"contact":["fullname","emailaddress1"]}' `
--allow-scripts yes
```

### UI
Create a model-driven app:
```console
dotnet new pp-app-model `
--output "src/Solutions.UI" `
--PublisherPrefix "tom" `
--LogicalName "warehouseapp" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Add a table to a model-driven app component:
```console
dotnet new pp-app-model-component `
--output "src/Solutions.UI" `
--EntityLogicalName "tom_warehouseitem" `
--SolutionRootPath "Declarations" `
--AppName "tom_warehouseapp" `,
--allow-scripts yes
```

Add an area to the sitemap:
```console
dotnet new pp-sitemap-area `
--output "src/Solutions.UI" `
--SolutionRootPath "Declarations" `
--AppName "tom_warehouseapp" `,
--allow-scripts yes
```

Add an group to the area:
```console
dotnet new pp-sitemap-group `
--output "src/Solutions.UI" `
--SolutionRootPath "Declarations" `
--AppName "tom_warehouseapp" `,
--allow-scripts yes
```

Add an subarea into the group:
```console
dotnet new pp-sitemap-subarea `
--output "src/Solutions.UI" `
--SolutionRootPath "Declarations" `
--EntityLogicalName "tom_warehouseitem" `
--AppName "tom_warehouseapp" `,
--allow-scripts yes
```

Create a main form for a table:
```console
dotnet new pp-entity-form `
--output "src/Solutions.UI" `
--FormType "main" `
--SolutionRootPath "Declarations" `
--EntitySchemaName "tom_warehouseitem" `
--allow-scripts yes
```

#### Form design

**Form Structure Hierarchy:**

```
┌──────────────────────────────────────────────────────────┐
│ Form                                                     │
│ ├─ Tab                                                   │
│   ├─ Column                                              │
│     ├─ Section                                           │
│       ├─ Row                                             │
│         ├─ Cell                                          │
│           └─ Control                                     │
└──────────────────────────────────────────────────────────┘
```


Create a new tab in the form:
```console
dotnet new pp-form-tab  `
--output "src/Solutions.UI"  `
--FormType "main"  `
--FormId $warehouseitemFormGuid `
--EntitySchemaName "${publisherPrefix}_warehouseitem" `
--SolutionRootPath "Declarations" `
--RemoveDefaultTab "True" `
--allow-scripts yes
```

Create a new column in the specific tab:
```console
dotnet new pp-form-column  `
--output "src/Solutions.UI"  `
--FormType "main"  `
--FormId $warehouseitemFormGuid `
--EntitySchemaName "${publisherPrefix}_warehouseitem" `
--SolutionRootPath "Declarations" `
--SetToTabFooter "False" `
--TabIndex 1 `
--ColumnWidth "75"
--allow-scripts yes
```

Create a new section in the specific column:
```console
dotnet new pp-form-section  `
--output "src/Solutions.UI"  `
--FormType "main"  `
--FormId $warehouseitemFormGuid `
--EntitySchemaName "${publisherPrefix}_warehouseitem" `
--SetToTabFooter "False" `
--TabIndex 1 `
--ColumnIndex 1 `
--SectionName "GENERAL"
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Create a new row in the specific section:
```console
dotnet new pp-form-row  `
--output "src/Solutions.UI"  `
--FormType "main"  `
--FormId $warehouseitemFormGuid `
--EntitySchemaName "${publisherPrefix}_warehouseitem" `
--SolutionRootPath "Declarations" `
--SetToTabFooter "False" `
--TabIndex 1 `
--ColumnIndex 1 `
--SectionIndex 1 `
--allow-scripts yes
```

Create a new cell in the specific row:
```console
dotnet new pp-form-cell  `
--output "src/Solutions.UI"  `
--RowIndex "1"  `
--SetToTabFooter "False" `
--TabIndex 1 `
--ColumnIndex 1 `
--SectionIndex 1 `
--FormType "main"  `
--DisplayName "Name"  `
--FormId $warehouseitemFormGuid `
--EntitySchemaName "${publisherPrefix}_warehouseitem" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Create a new control in the specific cell:
```console
dotnet new pp-form-cell-control  `
--output "src/Solutions.UI"  `
--AttributeType "Text"  `
--RowIndex "1"  `
--SetToTabFooter "False" `
--TabIndex 1 `
--ColumnIndex 1 `
--SectionIndex 1 
--AttributeLogicalName "${publisherPrefix}_name"  `
--FormType "main"  `
--FormId $warehouseitemFormGuid `
--EntitySchemaName "${publisherPrefix}_warehouseitem" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

### Security roles

Create a security role:
```console
dotnet new pp-security-role `
--output "src/Solutions.Security" `
--SolutionRootPath "Declarations" `
--rolename "Warehouse Manager" `
--allow-scripts yes
```

Add privileges to a security role:
```console
dotnet new pp-security-role-privilege `
--output "src/Solutions.Security" `
--SolutionRootPath "Declarations" `
--EntitySchemaName "tom_warehouseitem" `
--rolename "Warehouse Manager" `
--PrivilegeTypeAndLevel "[{ PrivilegeType: Read, Level: Global }, { PrivilegeType: Write, Level: Global }]" `
--allow-scripts yes
```

### Plugins
Initialize a new plugin:
```console
dotnet new pp-plugin `
--output "src/Plugins.Warehouse" `
--PublisherName "tomas" `
--SigningKeyFilePath "PluginKey.snk" `
--Company "NETWORG" `
--allow-scripts yes
```

Add new assembly:
```console
dotnet new pp-plugin-assembly-step `
--output "src/Solutions.Logic" `
--PluginProjectRootPath "..\\Plugins.Warehouse" `
--SolutionRootPath "Declarations" `
--allow-scripts yes
```

Add new step to the assembly:
```console
dotnet new pp-plugin-assembly-step `
--output "src/Solutions.Logic" `
--PrimaryEntity "tom_warehousetransaction" `
--PluginProjectName "Plugins.Warehouse" `
--PluginName "ValidateWarehouseTransactionPlugin" `
--Stage "Pre-validation" `
--SdkMessage "Create" `
--SolutionRootPath "Declarations" `
--FilteringAttributes "{tom_itemid, tom_quantity}" `
--AssemblyId "GUID to identifying your assembly" `
--allow-scripts yes
```

> [!TIP]  
> You can add component schema validation to your build process using [Power Platform MSBuild targets](https://github.com/TALXIS/tools-devkit-build).

## Tools

### Power Platform: Script Library template

A .NET project template for building Dataverse script libraries with TypeScript and Rollup. It scaffolds a `net462` project that uses Rollup to bundle TypeScript source (including npm dependencies) into a single UMD JavaScript file for use as a web resource.

### What you get
- A .NET SDK project targeting `net462` with `ProjectType=ScriptLibrary`
- TypeScript + Rollup at the project root:
  - `src/index.ts` — entry point with a skeleton `onLoad` handler
  - `rollup.config.mjs` — bundles to `build/<prefix>_<name>.js` as UMD
  - `tsconfig.json` — ES6 modules, strict mode
  - `package.json` — Rollup plugins, TypeScript, `@types/xrm`
- MSBuild target that runs `npm install` and `npm run build` (rollup) automatically on `dotnet build`
- UMD output creates a global namespace for Dataverse form/button references

### Prerequisites
- .NET SDK 6+ (`dotnet --version`)
- Node.js and npm (`node -v`, `npm -v`)

### Create a new project
```bash
dotnet new pp-script-library `
    -n solution.scripts `
    --PublisherPrefix "tom" `
    --LibraryName "inventory"
```

### Build
Build with `dotnet build` — the SDK runs npm install and Rollup automatically:
```bash
dotnet build
```

### Outputs
After building, you will find:
- `build/<prefix>_<name>.js` — UMD bundle (e.g., `build/tom_inventory.js`)
- `build/<prefix>_<name>.js.map` — source map
- `bin/Debug/net462/<prefix>_<name>.js` — copied by the Build SDK for deployment

### Workflow chain
1. **Create script library** — `pp-script-library` (this template)
2. **Add project reference** — from the solution project: `dotnet add reference ../solution.scripts/solution.scripts.csproj`
3. **Build the solution** — `dotnet build` (SDK auto-generates web resource data.xml and packs it)
4. **Reference from forms** — use `pp-form-event-handler` with `libraryName=<prefix>_<name>.js` and `functionName=<prefix>_<name>.ClassName.methodName`
5. **Reference from ribbon** — use `pp-ribbon-button` with `LibraryLogicalName=<prefix>_<name>`

### Using npm packages
Unlike the previous AMD approach, this template uses Rollup to bundle npm dependencies into the output. Install packages normally and import them:
```bash
cd solution.scripts
npm install liquidjs
```
```typescript
// src/index.ts
import { Liquid } from 'liquidjs';

export class DocumentGenerator {
    public static async generate(executionContext: Xrm.Events.EventContext): Promise<void> {
        const engine = new Liquid();
        // ...
    }
}
```
The dependency is bundled into the single output .js file automatically.

### Troubleshooting
- If `npm` is not found during `dotnet build`, ensure Node.js is installed and on PATH.
- To force a clean build:
  ```bash
  rm -rf node_modules build
  dotnet build
  ```
- For watch mode during development: `npm run start`


### Power Platform: Script Test Template

This template creates a test project for Power Platform JavaScript/TypeScript web resources using Jest. It provides a complete testing infrastructure with Xrm API mocks, helper functions, and integration with .NET test framework.

## Overview

The `pp-test-script` template generates a test project configured for testing Dataverse web resources (form scripts, ribbon commands, etc.). It includes:

- Jest test framework with jsdom environment
- Xrm API mocks for Dataverse client-side API
- Helper functions for creating test objects (forms, attributes, controls)
- Web resource loader utility for testing your scripts
- .NET project integration for running tests via `dotnet test`
- Automatic npm package installation

### Basic Usage

Create a script test project:

```console
dotnet new pp-test-script `
--output "tests/Script.Tests" `
--ScriptTestProjectName "Script.Tests" `
--ScriptLibraryPath "../src/Scripts.Warehouse" `
--allow-scripts yes
```

The template creates:

1. **.NET Test Project** - A .NET 8.0 project confiured to run Jest tests via `dotnet test`
2. **Jest Confiuration** - `jest.config.js` configured for jsdom environment
3. **Packae Configuration** - `package.json` with Jest dependencies
4. **jest-core Directory** - Reusable core library containing:
   - Xrm API mocks (`setupXrm.js`)
   - Helper functions (`helpers.js`)
   - Main export (`index.js`)
5. **Tests Directory** - Sample test structure with utilities
6. **Web Resource Loader** - Utility for loading and testing web resources

## Project Structure

```
Script.Tests/
├── jest-core/
│   ├── index.js          # Main export for jest-core
│   ├── setupXrm.js       # Xrm API mock setup
│   ├── helpers.js        # Helper functions for test objects
│   └── package.json      # jest-core package definition
├── tests/
│   └── utils/
│       └── loadWebRes.js  # Web resource loader utility
├── jest.config.js        # Jest configuration
├── package.json          # Project npm dependencies
└── Script.Tests.csproj   # .NET project file
```

### Basic Test Example

Create a test file in the `tests` directory (e.g., `tests/myScript.test.js`):

```javascript
const { setupXrm, resetXrmMocks, makeForm, makeAttr, makeControl } = require('../jest-core');
const { loadWebResource } = require('./utils/loadWebRes');

describe('My Form Script', () => {
  beforeEach(() => {
    setupXrm();
  });

  afterEach(() => {
    resetXrmMocks();
  });

  test('should set field value on form load', () => {
    // Arrange
    const nameAttr = makeAttr('');
    const nameControl = makeControl();
    const formContext = makeForm(
      { name: nameAttr },
      { name: nameControl }
    );

    // Load your web resource
    const webRes = loadWebResource('path/to/your/script.js');
    
    // Act - Call your function
    webRes.onFormLoad(formContext);

    // Assert
    expect(nameAttr.setValue).toHaveBeenCalledWith('Default Value');
  });
});
```

### Power Platform: Plugin Test Template

- FakeXrmEasy v2 documentation: `https://dynamicsvalue.github.io/fake-xrm-easy-docs/`

### What's included
- **`FakeXrmEasyTestBase.cs`**: a base class that:
  - creates an `IXrmFakedContext` via `MiddlewareBuilder` (`.AddCrud()`, `.UseCrud()`, `.UseMessages()`);
  - sets the license via `SetLicense(...)` (default is `Commercial`);
  - provides an `IOrganizationService` via `_context.GetOrganizationService()`.

### How to use `FakeXrmEasyTestBase.cs`
Inherit from the base class and use `_context` to seed data and `_service` to invoke the Organization Service.

```csharp
using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Xrm.Sdk;

namespace Plugins.Tests
{
    [TestClass]
    public class AccountPluginTests : FakeXrmEasyTestBase
    {
        [TestMethod]
        public void Creates_account_successfully()
        {
            // Arrange: seed in-memory data
            var account = new Entity("account")
            {
                Id = Guid.NewGuid(),
                ["name"] = "Test Account"
            };
            _context.Initialize(new List<Entity> { account });

            // Act: use IOrganizationService from the base
            var createdId = _service.Create(new Entity("contact"));

            // Assert: verify with context storage
            var created = _context.Data["contact"][createdId];
            Assert.IsNotNull(created);
        }
    }
}
```

### Important notes and dependencies
- **FakeXrmEasy license dependency**: calling `SetLicense(...)` is required before `.Build()`. If needed, replace `Commercial` with `RPL_1_5` or `NonCommercial` according to your usage terms.
- **Message executors dependency**: if you need custom message executors, uncomment in the base class
  `.AddFakeMessageExecutors(typeof(FakeXrmEasyTestBase).Assembly)` before `.UseMessages()`.
  - Dependency: custom executors become available only after their assembly is added.
  - Activation: `.UseMessages()` enables the message pipeline.


## Collaboration

We are happy to collaborate with developers and contributors interested in enhancing Power Platform development processes. If you have feedback, suggestions, or would like to contribute, please feel free to submit issues or pull requests.

### Local building and debugging

**Build the template package locally:**
```sh
dotnet pack --configuration Debug
```

The `.nupkg` is output to `src/Dataverse/bin/Debug/`. To use it with the CLI, add it as a local NuGet source (see [cross-repo instructions](https://github.com/TALXIS/tools-cli#working-with-all-three-repos-locally)).

For `dotnet new` (standalone template usage outside the CLI):
```sh
dotnet new install src/Dataverse/bin/Debug/TALXIS.DevKit.Templates.Dataverse.*.nupkg --force
```

Or use the VS Code task: Command Palette → "Tasks: Run Task" → "Update local templates".

### Working with all three repos locally

See the [tools-cli README](https://github.com/TALXIS/tools-cli#working-with-all-three-repos-locally) for instructions on testing local versions of the CLI, templates, and build SDK together.

### Versioning & Release

Releases are published through [GitHub Releases](https://github.com/TALXIS/tools-devkit-templates/releases):

1. Go to **Releases** → **Draft a new release**
2. Create a tag in the format `vX.Y.Z` (e.g. `v1.17.0`)
3. Write the changelog in the release body
4. Click **Publish release**

The publish workflow builds the NuGet package with the tag version and pushes it to [nuget.org](https://www.nuget.org/packages/TALXIS.DevKit.Templates.Dataverse). Release notes are embedded in the package.

## Contact us

For further information or to discuss potential use cases for your team, please reach out to us at hello@networg.com.