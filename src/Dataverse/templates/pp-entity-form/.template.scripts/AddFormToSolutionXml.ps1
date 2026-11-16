param(
    [Parameter(Mandatory=$true)]
    [string]$formId
)

# Resolve the relative path to an absolute path (to support other OSes)
$solutionPath = (Resolve-Path -Path '__solution-root-path__/Other/Solution.xml').Path

# Load with whitespace preserved so only the new RootComponent line changes.
# A plain [xml] load and Save re-indents the file and splits every
# <X xsi:nil="true"></X> element across two lines.
$File = New-Object System.Xml.XmlDocument
$File.PreserveWhitespace = $true
$File.Load($solutionPath)
$rootComponents = $File.SelectSingleNode("//RootComponents")

$newComponent = $File.CreateElement("RootComponent")
$newComponent.SetAttribute("type", '60')
$newComponent.SetAttribute("id", "$formId")
<!--#if (FormType != "dialog") -->
$newComponent.SetAttribute("behavior", '0')
<!--#endif -->

# Insert after the last RootComponent, reusing its indentation
$lastComponent = $rootComponents.SelectSingleNode("RootComponent[last()]")
if ($lastComponent) {
    $indent = "`n      "
    if ($lastComponent.PreviousSibling -is [System.Xml.XmlWhitespace]) {
        $indent = $lastComponent.PreviousSibling.Value
    }
    $whitespace = $rootComponents.InsertAfter($File.CreateWhitespace($indent), $lastComponent)
    $null = $rootComponents.InsertAfter($newComponent, $whitespace)
} else {
    $null = $rootComponents.AppendChild($newComponent)
}

# Save the updated XML back to the file
$File.Save($solutionPath)
