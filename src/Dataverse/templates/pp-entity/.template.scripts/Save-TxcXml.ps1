<#
.SYNOPSIS
    Saves an XmlDocument to disk with consistent formatting:
    UTF-8 without BOM, LF line endings, and expanded (non-self-closing) empty elements.
.PARAMETER Document
    The XmlDocument to save.
.PARAMETER Path
    Absolute path to write to.
.PARAMETER ExpandEmptyElements
    Element local names that must NOT be self-closing even when empty.
    XmlDocument collapses <Foo></Foo> to <Foo /> — this restores them.
#>
function Save-TxcXml {
    param(
        [xml]$Document,
        [string]$Path,
        [string[]]$ExpandEmptyElements = @()
    )

    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Indent = $true
    $settings.NewLineChars = "`n"
    $settings.NewLineHandling = [System.Xml.NewLineHandling]::None
    $settings.OmitXmlDeclaration = $false
    $settings.Encoding = [System.Text.UTF8Encoding]::new($false)

    $ms = New-Object System.IO.MemoryStream
    $writer = [System.Xml.XmlWriter]::Create($ms, $settings)
    try { $Document.Save($writer) } finally { $writer.Close() }

    $content = [System.Text.UTF8Encoding]::new($false).GetString($ms.ToArray())

    # Normalize any stray CRLF to LF
    $content = $content.Replace("`r`n", "`n").Replace("`r", "`n")

    # Expand self-closing empty elements back to explicit open/close pairs
    foreach ($tag in $ExpandEmptyElements) {
        $escaped = [regex]::Escape($tag)
        $content = [regex]::Replace($content, "<$escaped(\s[^>]*)?\s*/>", {
            param($m)
            $attrs = $m.Groups[1].Value
            "<$tag$attrs></$tag>"
        })
    }

    # Re-normalize xsi:nil tags to single line (XmlDocument may expand them)
    $content = [regex]::Replace($content, '(xsi:nil="true")>\s*\r?\n\s*</', '$1></')

    [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::new($false))
}
