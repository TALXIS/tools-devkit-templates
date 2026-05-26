# Reqnroll + Playwright BDD scaffold for Power Apps

This project is a generated scaffold for testing a Power Apps model-driven app with **Reqnroll**, **Playwright**, and **MSTest**.

## Prerequisites

- .NET 8 SDK (LTS)
- Playwright browser binaries — install with `pwsh bin/Debug/net8.0/playwright.ps1 install chromium` after the first `dotnet build`

## Project structure

- `Features/` - Gherkin scenarios
- `Support/Bindings/` - standardized model-driven app bindings
- `Support/` - hooks, configuration, and Xrm bridge helpers
- `Tests/` - offline reflection and helper tests

## Running tests

```bash
dotnet restore
dotnet test
dotnet test --list-tests
```

The sample feature is tagged `@live` and `@ignore` so offline runs stay green while still proving discovery and binding resolution.

## Configuration

Update `appsettings.json` or environment variables:

- `TXC_ENVIRONMENT_URL`
- `TXC_APP_NAME`
- `TXC_HEADLESS`
- `TXC_SLOWMO`
- `TXC_TIMEOUT`
- `TXC_STORAGE_STATE_PATH`
- `TXC_SCREENSHOT_ON_FAILURE`
- `TXC_TRACING_ENABLED`
- `TXC_OUTPUT_PATH`

## Two-tier approach

1. Standard model-driven app surfaces use the frozen bindings in `Support/Bindings/`.
2. Non-standard UI belongs in custom step definitions outside the standardized binding set.

## Reporting

Artifacts are written to `{AppContext.BaseDirectory}/{OutputPath}` — by default this resolves to `bin/<config>/net8.0/TestResults/`.

To collect artifacts in a predictable project-relative directory, use:

```bash
dotnet test --results-directory ./TestResults
```

Default artifact layout inside the output directory:

- `screenshots/` — failure screenshots (when `ScreenshotOnFailure` is enabled)
- `traces/` — Playwright traces (when `TracingEnabled` is enabled)
