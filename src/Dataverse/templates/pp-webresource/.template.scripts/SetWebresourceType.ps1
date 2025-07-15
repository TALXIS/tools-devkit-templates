$filePath = "webresourcefilepathexample"
$dataXmlFilePath = "SolutionDeclarationsRoot\WebResources\examplepublisher_fileexamplename.data.xml"

$extension = [System.IO.Path]::GetExtension($filePath).ToLower()

$type

switch ($extension) {
    '.htm' { $type = 1 }
    '.html' { $type = 1 }
    '.css' { $type = 2 }
    '.js' { $type = 3 }
    '.xml' { $type = 4 }
    '.png' { $type = 5 }
    '.jpg' { $type = 6 }
    '.gif' { $type = 7 }
    '.xap' { $type = 8 }
    '.xsl' { $type = 9 }
    '.xslt' { $type = 9 }
    '.ico' { $type = 10 }
    '.svg' { $type = 11 }
    '.resx' { $type = 12 }
    default { $type = 0 } 
}


$content = Get-Content -Path $dataXmlFilePath -Raw
$content = $content -replace "wrtypeexample", $type
Set-Content -Path $dataXmlFilePath -Value $content