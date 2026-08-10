# Power Apps Template - starter

An opinionated **Vite + TypeScript + React** starter template for building Power Apps code apps.

Designed for common app scenarios, easy extensibility, and minimal setup.

---

## Highlights
- **Modern tooling** - Vite, TypeScript, and React
- **Out-of-box styling** - Tailwind, shadcn/ui components, and theming out of the box
- **Batteries included** - Curated libraries pre-wired for common scenarios
- **Standard patterns** - Industry standard patterns and practices
- **Agent friendly** - Optimized for use with coding agents
---

## Pre-installed libraries
- [Tailwind CSS](https://tailwindcss.com/) - utility-first CSS framework
- [shadcn/ui](https://ui.shadcn.com/) - pre-installed UI components
- [React Router](https://reactrouter.com/) - pages, routing
- [Zustand](https://zustand.docs.pmnd.rs/) - state management
- [Tanstack Query](https://tanstack.com/query/latest) - data fetching, state management
- [Tanstack Table](https://tanstack.com/table/latest) - interactive tables, datagrids
- [Lucide](https://lucide.dev/) - icons

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
