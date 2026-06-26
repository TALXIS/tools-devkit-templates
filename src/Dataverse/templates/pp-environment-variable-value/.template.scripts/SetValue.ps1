$ErrorActionPreference = 'Stop'

$valuesJsonPath = '__solution-root-path__/environmentvariabledefinitions/__definition-logical-name__/environmentvariablevalues.json'

if (-not (Test-Path $valuesJsonPath)) {
    Write-Error "environmentvariablevalues.json stub not found at $valuesJsonPath — template content was not extracted."
    exit 1
}

# The Value parameter is injected by the template engine into the single-quoted here-string below.
# Single-quoted here-strings preserve every character literally (no escapes are processed), so
# arbitrary user values including embedded double quotes, backslashes and JSON fragments survive.
$rawValue = @'
__envvar-raw-value__
'@

# Here-strings always carry a trailing newline; trim it so the persisted value is a single token.
$rawValue = $rawValue -replace "`r?`n\z", ""

$payload = [ordered]@{
    environmentvariablevalues = [ordered]@{
        environmentvariablevalue = [ordered]@{
            '@environmentvariablevalueid' = '__envvar-value-id__'
            iscustomizable = '1'
            value = $rawValue
        }
    }
}

# ConvertTo-Json handles all character escaping correctly for the value payload.
$json = $payload | ConvertTo-Json -Depth 10

# Write with UTF-8 (no BOM) to match other unpacked solution artifacts.
[System.IO.File]::WriteAllText((Resolve-Path -Path $valuesJsonPath).Path, $json + "`n", (New-Object System.Text.UTF8Encoding($false)))
