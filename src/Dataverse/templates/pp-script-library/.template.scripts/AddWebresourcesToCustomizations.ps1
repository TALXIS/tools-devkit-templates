# Get customizations.xml
$customizations = Get-ChildItem -Path . -Filter Declarations/Other/Customizations.xml | Select-Object -First 1
[xml]$xml = Get-Content $customizations.FullName -Raw

# Find the Workflows node
$workflows = $xml.SelectSingleNode("//Workflows")

# Create the new <Webresources /> element
$webresources = $xml.CreateElement("WebResources")

# Insert the new element after <Workflows />
$parentNode = $workflows.ParentNode
$parentNode.InsertAfter($webresources, $workflows)

# Save the updated XML back to the file
$xml.Save($customizations.FullName)

