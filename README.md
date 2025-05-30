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
--PublisherPrefix "tom" `
--LogicalName "itemid" `
--DisplayName "Item" `
--ReferencedEntityName "tom_warehouseitem" `
--SolutionRootPath "Declarations" `
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
--PublisherPrefix "tom" `
--EntityLogicalName "warehouseitem" `
--SolutionRootPath "Declarations" `
--AppName "warehouseapp" `,
--allow-scripts yes
```

Add an area to the sitemap:
```console
dotnet new pp-sitemap-area `
--output "src/Solutions.UI" `
--PublisherPrefix "tom" `
--AreaTitle "Warehouse Item" `
--SolutionRootPath "Declarations" `
--AppName "warehouseapp" `,
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

Create a row in the main form:
```console
dotnet new pp-form-row `
--output "src/Solutions.UI" `
--AttributeType "WholeNumber" `
--PublisherPrefix "tom" `
--LogicalName "availablequantity" `
--FormType "main" `
--DisplayName "Available Quantity" `
--EntityName "tom_warehouseitem" `
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

> [!TIP]  
> You can add component schema validation to your build process using [Power Platform MSBuild targets](https://github.com/TALXIS/tools-devkit-build).

## Collaboration

We are happy to collaborate with developers and contributors interested in enhancing Power Platform development processes. If you have feedback, suggestions, or would like to contribute, please feel free to submit issues or pull requests.

### Local building and debugging

#### Using your local version of templates

Run the following terminal command in the folder `src/Dataverse/templates`:

```
dotnet new install "." --force
```

## Contact us

For further information or to discuss potential use cases for your team, please reach out to us at hello@networg.com.