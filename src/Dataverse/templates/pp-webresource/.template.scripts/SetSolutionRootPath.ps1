$solutionRootPath = $null
$currentDirectory = (Get-Location).Path

# Other/Solution.xml directly next to the csproj means the project folder itself is the solution root
if (Test-Path -LiteralPath (Join-Path $currentDirectory "Other/Solution.xml") -PathType Leaf) {
    $solutionRootPath = "."
}

$csprojFiles = @(
    Get-ChildItem `
        -LiteralPath $currentDirectory `
        -Filter "*.csproj" `
        -File
)

if ($csprojFiles.Count -gt 1) {
    $fileNames = $csprojFiles.Name -join ", "
    throw "Multiple .csproj files found in '$currentDirectory': $fileNames"
}

if ([string]::IsNullOrWhiteSpace($solutionRootPath) -and $csprojFiles.Count -eq 1) {
    $csprojPath = $csprojFiles[0].FullName

    try {
        [xml]$projectXml = Get-Content `
            -LiteralPath $csprojPath `
            -Raw `
            -ErrorAction Stop

        $solutionRootPathNode = $projectXml.SelectSingleNode(
            "/*[local-name()='Project']/*[local-name()='PropertyGroup']/*[local-name()='SolutionRootPath']"
        )

        if ($null -ne $solutionRootPathNode) {
            $value = $solutionRootPathNode.InnerText.Trim()

            if (-not [string]::IsNullOrWhiteSpace($value)) {
                $solutionRootPath = $value
            }
        }
    }
    catch {
        Write-Warning "Failed to read '$csprojPath': $($_.Exception.Message)"
    }
}


if ([string]::IsNullOrWhiteSpace($solutionRootPath)) {
    $solutionXmlFiles = @(
        Get-ChildItem `
            -LiteralPath $currentDirectory `
            -Filter "Solution.xml" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Directory.Name -ieq "Other"
        }
    )

    if ($solutionXmlFiles.Count -gt 1) {
        $paths = $solutionXmlFiles.FullName -join [Environment]::NewLine

        throw @"
Multiple Other/Solution.xml files found under '$currentDirectory':

$paths
"@
    }

    if ($solutionXmlFiles.Count -eq 1) {
        # .../SolutionRoot/Other/Solution.xml
        $solutionRootDirectory =
            $solutionXmlFiles[0].Directory.Parent.FullName

        $solutionRootPath = [System.IO.Path]::GetRelativePath(
            $currentDirectory,
            $solutionRootDirectory
        )
    }
}

if ([string]::IsNullOrWhiteSpace($solutionRootPath)) {
    throw "Failed to determine SolutionRootPath."
}

& (Join-Path $PSScriptRoot 'ReplacePlaceholder.ps1') `
    -Path $currentDirectory `
    -Placeholder "__solution-root-path__" `
    -Replacement $solutionRootPath