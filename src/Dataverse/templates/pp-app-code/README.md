# Power Apps Template - starter

An opinionated **Vite + TypeScript + React** starter template for building Power Apps code apps.

Designed for common app scenarios, easy extensibility, and minimal setup.

---

## Highlights
- **Modern tooling** - Vite, TypeScript, and React
- **Out-of-box styling** - Fluent UI components, light/dark theming and toasts out of the box
- **Dataverse-native controls** - TALXIS base controls (fields, lookups, grid) wired up with a PCF context
- **Batteries included** - Curated libraries pre-wired for common scenarios
- **Standard patterns** - Industry standard patterns and practices
- **Agent friendly** - Optimized for use with coding agents
---

## Pre-installed libraries
- [Fluent UI React v9](https://react.fluentui.dev/) - Microsoft's design system: components, theming (`FluentProvider`), styling (`makeStyles` + design tokens), toasts
- [TALXIS base controls](https://github.com/TALXIS/base-controls) - Dataverse field controls (`TextField`, `Decimal`, `OptionSet`, `Lookup`, `DateTime`, ...) and the `Grid`, with formatting from user settings
- [React Router](https://reactrouter.com/) - pages, routing
- [Zustand](https://zustand.docs.pmnd.rs/) - state management
- [Tanstack Query](https://tanstack.com/query/latest) - data fetching, state management
- [Tanstack Table](https://tanstack.com/table/latest) - interactive tables, datagrids
- [Fluent UI Icons](https://github.com/microsoft/fluentui-system-icons) - icons (`@fluentui/react-icons`)

---

## TALXIS base controls
Base controls are built for the Power Apps Component Framework and read a PCF `context`. The starter's
`PcfProvider` (`src/providers/pcf-provider.tsx`) supplies one through `PcfContextProvider`: a context
generated for a non-PCF host (formatting, user settings, dialogs, ...) carrying the current Fluent v9
theme, so controls follow light/dark mode, plus two surfaces the app answers itself from
`src/providers/pcf-host.ts`:

- `utils.getEntityMetadata` - from the tables you register with `registerEntities()` (a `Lookup`
  needs its target's metadata)
- `navigation.openForm` - navigates to a record's page in the app, from each entity's `formPath`
  (the router registers the navigation with `setHostNavigate`)

```ts
registerEntities({
  logicalName: "tom_warehouseitem",
  displayName: "Warehouse Item",
  primaryIdAttribute: "tom_warehouseitemid",
  primaryNameAttribute: "tom_name",
  formPath: (id) => `/items/${id}`,
})
```

Inside any page, get the context with `usePcfContext()` and pass it to a control:

```tsx
const context = usePcfContext()
<Decimal context={context} parameters={{ value: { raw: qty, type: "Whole.None" } }}
  onNotifyOutputChanged={(o) => typeof o.value !== "string" && setQty(o.value ?? null)} />
```

A control reports a value it can't parse as the raw text (a string), so check the type before storing it.

- **React 18:** base controls (and the AG Grid behind `Grid`) support React up to 18, so the starter
  pins React 18. The `overrides` entry in `package.json` lets base controls, which declare React
  16/17 as their peer range, use the app's React 18.
- **Grid licence:** `Grid` uses AG Grid Enterprise modules. Without a licence key (the `LicenseKey`
  parameter) it runs as an AG Grid trial, with a console notice and a watermark.

---

## Parameters
| Parameter | Required | Description |
|-----------|----------|-------------|
| `DisplayName` | No | Display name shown for the app. |
| `AppName` | Yes | Logical name of the app, without the publisher prefix (e.g. `warehousepicking`). Used as-is for the schema name, the generated `.meta.xml` file name, and the package folder when this project is referenced from a Solution project. Must be unique among all Code Apps referenced by the same solution. |

Example:
```console
dotnet new pp-app-code `
--output "src/CodeApps.WarehousePicking" `
--DisplayName "Warehouse Picking" `
--AppName "warehousepicking"
```
