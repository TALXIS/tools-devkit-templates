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
Add a column to table:
```console
dotnet new pp-entity-attribute `
--output "src/Solutions.DataModel" `
--EntitySchemaName "tom_warehouseitem" `
--AttributeType "WholeNumber" `
--PublisherPrefix "tom" `
--LogicalName "quantity" `
--DisplayName "Quantity" `
--SolutionRootPath "Declarations" `
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