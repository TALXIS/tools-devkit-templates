<#
.SYNOPSIS
    Saves an XmlDocument to disk with consistent formatting:
    UTF-8 without BOM, LF line endings, and expanded (non-self-closing) empty elements.
    
.PARAMETER Document
    The XmlDocument to save.
    
.PARAMETER Path
    Absolute path to write to.
    
.PARAMETER ExpandEmptyElements
    Array of element names that must NOT be self-closing even when empty.
    XmlDocument collapses <Foo></Foo> to <Foo /> — this parameter restores them.
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
    try {
        $Document.Save($writer)
    } finally {
        $writer.Close()
    }

    $content = [System.Text.UTF8Encoding]::new($false).GetString($ms.ToArray())

    # Normalize any remaining CRLF to LF
    $content = $content.Replace("`r`n", "`n").Replace("`r", "`n")

    # Expand self-closing empty elements back to explicit open/close pairs
    foreach ($tag in $ExpandEmptyElements) {
        $content = [regex]::Replace($content, "<$([regex]::Escape($tag))(\s[^>]*)?\s*/>", {
            param($m)
            $attrs = $m.Groups[1].Value
            "<$tag$attrs></$tag>"
        })
    }

    # Normalize xsi:nil tags to single-line (XmlDocument may re-introduce whitespace text nodes)
    $content = [regex]::Replace($content, '(xsi:nil="true")>\s*\n\s*</', '$1></')

    [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::new($false))
}
