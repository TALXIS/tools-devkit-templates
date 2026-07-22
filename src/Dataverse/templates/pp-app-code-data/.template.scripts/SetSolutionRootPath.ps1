# Code app projects have no solution csproj of their own, so the root path is
# detected from the model solution passed via the ModelSolutionPath parameter.
$solutionRootPath = $null
$modelSolutionDirectory = (Resolve-Path "modelsolutionexamplepath").Path

$csprojFiles = @(
    Get-ChildItem `
        -LiteralPath $modelSolutionDirectory `
        -Filter "*.csproj" `
        -File
)

if ($csprojFiles.Count -gt 1) {
    $fileNames = $csprojFiles.Name -join ", "
    throw "Multiple .csproj files found in '$modelSolutionDirectory': $fileNames"
}

if ($csprojFiles.Count -eq 1) {
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
            -LiteralPath $modelSolutionDirectory `
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
Multiple Other/Solution.xml files found under '$modelSolutionDirectory':

$paths
"@
    }

    if ($solutionXmlFiles.Count -eq 1) {
        # .../SolutionRoot/Other/Solution.xml
        $solutionRootDirectory =
            $solutionXmlFiles[0].Directory.Parent.FullName

        $solutionRootPath = [System.IO.Path]::GetRelativePath(
            $modelSolutionDirectory,
            $solutionRootDirectory
        )
    }
}

if ([string]::IsNullOrWhiteSpace($solutionRootPath)) {
    throw "Failed to determine SolutionRootPath from '$modelSolutionDirectory'."
}

& (Join-Path $PSScriptRoot 'ReplacePlaceholder.ps1') `
    -Path (Get-Location).Path `
    -Placeholder "__solution-root-path__" `
    -Replacement $solutionRootPath
