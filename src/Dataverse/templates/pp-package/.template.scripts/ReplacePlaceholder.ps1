param(
    [Parameter(Mandatory)][Alias('FilePath')][string]$Path,
    [Parameter(Mandatory)][string]$Placeholder,
    [Parameter(Mandatory)][string]$Replacement
)

$ErrorActionPreference = 'Stop'

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

function Invoke-RenameIfMatches
{
    param([string]$TargetPath, [string]$Placeholder, [string]$Replacement)

    $name = Split-Path $TargetPath -Leaf

    if ($name.Contains($Placeholder))
    {
        $newName = $name.Replace($Placeholder, $Replacement)
        if (Test-Path -LiteralPath $TargetPath -PathType Leaf)
        {
            # A file replaces an existing one on re-run; Rename-Item fails when the target
            # exists, even with -Force, and leaves the placeholder-named file behind.
            Move-Item -LiteralPath $TargetPath -Destination (Join-Path (Split-Path $TargetPath -Parent) $newName) -Force
        }
        elseif (Test-Path -LiteralPath (Join-Path (Split-Path $TargetPath -Parent) $newName))
        {
            # Not Move-Item for folders: onto an existing folder it would nest the source inside
            # it. Leave both in place and say so rather than merge two folders' contents.
            Write-Warning "Not renaming folder $name -> ${newName}: $newName already exists."
            return
        }
        else
        {
            Rename-Item -LiteralPath $TargetPath -NewName $newName
        }
        Write-Host "Renamed: $name -> $newName"
    }
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
