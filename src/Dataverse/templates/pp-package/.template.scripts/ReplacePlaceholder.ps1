param(
    [Parameter(Mandatory)][Alias('FilePath')][string]$Path,
    [Parameter(Mandatory)][string]$Placeholder,
    [Parameter(Mandatory)][string]$Replacement
)

if (-not (Test-Path -LiteralPath $Path))
{
    Write-Error "Path not found: $Path"
    exit 1
}

function Invoke-ReplaceInFileContent
{
    param([string]$TargetPath, [string]$Placeholder, [string]$Replacement)

    $content = Get-Content -LiteralPath $TargetPath -Raw

    if ($null -ne $content -and $content.Contains($Placeholder))
    {
        $content = $content.Replace($Placeholder, $Replacement)
        Set-Content -LiteralPath $TargetPath -Value $content -NoNewline
        Write-Host "Replaced placeholder in content: $TargetPath"
    }
}

function Merge-Directory
{
    param([string]$SourceDir, [string]$DestinationDir)

    foreach ($child in Get-ChildItem -LiteralPath $SourceDir -Force)
    {
        $target = Join-Path $DestinationDir $child.Name

        if ($child.PSIsContainer -and (Test-Path -LiteralPath $target -PathType Container))
        {
            Merge-Directory -SourceDir $child.FullName -DestinationDir $target
        }
        else
        {
            if (Test-Path -LiteralPath $target) { Write-Warning "Overwriting existing item: $target" }
            Move-Item -LiteralPath $child.FullName -Destination $target -Force
        }
    }

    Remove-Item -LiteralPath $SourceDir -Force
}

function Invoke-RenameIfMatches
{
    param([string]$TargetPath, [string]$Placeholder, [string]$Replacement)

    $name = Split-Path $TargetPath -Leaf

    if (-not $name.Contains($Placeholder)) { return }

    $parent = Split-Path $TargetPath -Parent
    $source = [System.IO.Path]::GetFullPath($TargetPath)

    # Replacement may be a relative path (e.g. "." or "sub\dir"), so resolve against the parent
    $destination = [System.IO.Path]::GetFullPath((Join-Path $parent ($name.Replace($Placeholder, $Replacement))))

    if ($source -ieq $destination) { return }

    if ($destination.StartsWith($source + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase))
    {
        throw "Cannot move '$source' into its own subfolder '$destination'."
    }

    if (-not (Test-Path -LiteralPath $destination))
    {
        $destinationParent = Split-Path $destination -Parent

        if (-not (Test-Path -LiteralPath $destinationParent))
        {
            New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
        }

        Move-Item -LiteralPath $TargetPath -Destination $destination
        Write-Host "Renamed: $source -> $destination"
        return
    }

    if ((Test-Path -LiteralPath $source -PathType Container) -and (Test-Path -LiteralPath $destination -PathType Container))
    {
        Merge-Directory -SourceDir $source -DestinationDir $destination
        Write-Host "Merged: $source -> $destination"
        return
    }

    Write-Warning "Overwriting existing item: $destination"
    Move-Item -LiteralPath $TargetPath -Destination $destination -Force
}

if (Test-Path -LiteralPath $Path -PathType Leaf)
{
    Invoke-ReplaceInFileContent -TargetPath $Path -Placeholder $Placeholder -Replacement $Replacement
    Invoke-RenameIfMatches     -TargetPath $Path -Placeholder $Placeholder -Replacement $Replacement
}
else
{
    Get-ChildItem -LiteralPath $Path -Recurse -File | ForEach-Object {
        Invoke-ReplaceInFileContent -TargetPath $_.FullName -Placeholder $Placeholder -Replacement $Replacement
    }

    # Rename bottom-up so child paths stay valid while parents are still being iterated
    Get-ChildItem -LiteralPath $Path -Recurse |
        Sort-Object -Property FullName -Descending |
        ForEach-Object {
            Invoke-RenameIfMatches -TargetPath $_.FullName -Placeholder $Placeholder -Replacement $Replacement
        }

    Invoke-RenameIfMatches -TargetPath $Path -Placeholder $Placeholder -Replacement $Replacement
}
