$filePath = "webresourcefilepathexample"
$dataXmlFilePath = "__solution-root-path__/WebResources\examplepublisher_fileexamplename.data.xml"

$extension = [System.IO.Path]::GetExtension($filePath).ToLower()

$type

switch ($extension) {
    '.htm' { $type = 1 }
    '.html' { $type = 1 }
    '.css' { $type = 2 }
    '.js' { 
        $type = 3 
        .template.scripts\AddBuildTarget.ps1
    }
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
$content = $content.Replace("`r`n", "`n").Replace("`r", "`n")
[System.IO.File]::WriteAllText($dataXmlFilePath, $content, [System.Text.UTF8Encoding]::new($false))