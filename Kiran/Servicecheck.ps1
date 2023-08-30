function ReportMaker {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Services","Roles","Registry")]
        [string]$test
    )


    #reference CSV file
    $reference = Import-Csv ".\References\$test.csv"


    $Scripts = @{
    Roles= { Get-WindowsFeature | Select Name,Installed }

    Services = { Get-Service | Select Name, @{Name='StartType';Expression={
        switch ($_.StartType) {'Automatic' { 'Automatic' }
                            'Disabled' { 'Disabled' }
                            'Manual' { 'Manual' }}}}}

    Registry={
        $output=@()
        foreach($registry in $using:reference){
        $value=Get-ItemProperty -Path "$($Registry.Name)"|select -expandproperty $Registry.key
        $output+=[pscustomobject]@{
            Name=$registry.Name
            Key=$registry.Key
            Value=$value
            }}
        $output
          }
    }

    $ValidateColumn = @{
    Roles= "Installed"
    Services = "StartType"
    Registry="Value"
    }

    $DisplayColumn = @{
    Roles= @("Name","Installed")
    Services = @("Name","StartType")
    Registry=@("Name","Key","Value")
    }

    # Get the columns from the reference CSV file
    $columns = $reference[0].PSObject.Properties.Name
    #write-host "$columns"
    #$credentials=Get-Credential
    # Get the services from the remote computer
    $job = Invoke-Command -ComputerName $ComputerName -ScriptBlock $Scripts.$test -AsJob
    start-sleep -Seconds 2
    Wait-Job $job
    start-sleep -Seconds 2

    $result=receive-job $job
    $print=Import-Clixml $result
    write-host $print
    #write-host $result
    # Compare the reference and services
    $Compared = Compare-Object $reference $result -Property $columns -IncludeEqual
    $compared >a.txt
    $processed=foreach($reference_row in $compared){
        #looping only on the equal and reference data == & <=
        #reset all variable
        $HTML_verbose=""
        $changedProperty=@()
        if($reference_row.sideIndicator -ne "=>"){
            $result_row=$result|where {$_.Name -eq $reference_row.name}
            if($reference_row.sideIndicator -eq "<="){
                write-host $result_row
                if($result_row){
                    foreach ($column in $columns) {
                        if ($reference_row.$column -ne $result_row.$column) {
                            $changedProperty+=$column
                            $HTML_verbose="$column : expected <b>$($reference_row.$column)</b> got <b>$($result_row.$column)</b>"
                        }
                    }
                }
                else{
                    $changedProperty="Doesn't exist"
                    $HTML_verbose="Name Doesn't exist"
                }
                $status="Failed"
                $HTML_status="<span style=`"color:Tomato;`">Failed</span>"
            }
            elseif($reference_row.sideIndicator -eq "=="){
                $HTML_status="<span style=`"color:Green;`">Passed</span>"
                $status="Passed"
            }

            $props = @{}

            #add the reference columns
            foreach ($column in $columns) {
                $props[$column] = $reference_row.$column
            }

            #$col=$ValidateColumn[$test]
            #add the differencing column from result
            $props.Result=$result_row.($ValidateColumn[$test])
            
            #add some default additional columns
            $props.Status = $status
            $props.HTML_status=$HTML_status
            $props.HTML_Verbose=$HTML_verbose
            $props.Server=$ComputerName
            $props.Changed="$changedProperty"
            
            
            [PSCustomObject]$props
            
            <#[PSCustomObject]@{
                Name=$reference_row.Name
                StartType=$reference_row.StartType
                Result=$result_row.StartType
                Status = $status
                Verbose=$verbose
                Server=$ComputerName
            }#>
        }
    }
    #$processed contains all the objects
    $Html= $processed|select Server,Name,Key, Value, Result,@{l="Status";e={$_.HTML_Status}}, @{l="Verbose";e={$_.HTML_Verbose}} |sort Name|ConvertTo-Html
    $failed=($processed|where status -eq "Failed").count
    $passed=($processed|where status -eq "passed").count
    #$processed|select Name, changed
    $styledHTML=@"
    <!DOCTYPE html>
    <html>
    <head>
    <title>$test - $computername</title>
    <style>
    table {
      font-family: Arial, Helvetica, sans-serif;
      border-collapse: collapse;
      width: 100%;
    }

    p {text-align: center;}
    
    td, th {
      border: 1px solid #ddd;
      padding: 8px;
    }
    
    tr:nth-child(even){background-color: #f2f2f2;}
    
    tr:hover {background-color: #ddd;}
    
    th {
      padding-top: 12px;
      padding-bottom: 12px;
      text-align: left;
      background-color: #04AA6D;
      color: white;
    }
    </style>
    </head>
    <body>
    <p>Report last ran at $(get-date) <b>$failed</b> Failed out of <b>$($processed.count)</b> <br/></p>
    $Html
    </body>
    </html>
"@
    $decoded=[System.Net.WebUtility]::HtmlDecode($StyledHTML)
    $decoded|Out-File ".\$test - $computername.html"
    #$output
    #$result|select Name, startType, sideIndicator, @{l="ServerName";e={"$computername"}} | format-table

}

#ReportMaker