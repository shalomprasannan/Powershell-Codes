function ConvertFrom-HtmlTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Html
    )

    $doc = New-Object -Com "HTMLFile"
    $doc.IHTMLDocument2_write($Html)
    $table = $doc.getElementsByTagName("table") | Select-Object -First 1

    $headers = $table.getElementsByTagName("th") | ForEach-Object { $_.innerText.Trim() }
    $rows = $table.getElementsByTagName("tr") | Select-Object -Skip 1

    $objects = foreach ($row in $rows) {
        $cells = $row.getElementsByTagName("td") | ForEach-Object { $_.innerText.Trim() }
        $props = @{}
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $props[$headers[$i]] = $cells[$i]
        }
        [PSCustomObject]$props
    }

    return $objects
}


$ie = New-Object -ComObject InternetExplorer.Application
$ie.Visible=$false
$ie.Silent=$true
$ie.Navigate("file:///C:/temp/GPOReport.html")

###########
$path="windows settings\security settings\Password Public Key Policies\Certificate Services Client - Auto-Enrollment Settings"
$paths=$path.split("\")
$node=$ie.document.body

foreach($path in $paths){
$temp=$node.getElementsByClassName("container")|where {$_.previoussibling.firstchild.innerHTML -match ".*$path.*"}
if(!$temp){
    $last=$node|where {$_.previoussibling.firstchild.innerHTML -match ".*$path.*"}
    if($last){
      $node=$last
    }
  }
  else{
    $node=$temp
  }
}

$table=$node.getElementsByTagName("Table")
$table=ConvertFrom-HtmlTable $table[0].outerHTML

$table|where Policy -eq "Automatic certificate management"
