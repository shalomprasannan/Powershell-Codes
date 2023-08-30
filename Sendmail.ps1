$paths=@() # add here
$threshold=70000
$maxLimit=100000


$importanceThreshold =90 #at 90% it will set it the high priority flag
$importance="normal"
$Alert="Alert"
$mail=""
#below code for monitoring the script and Task scheduler
$info=""


foreach($path in $paths){
    $parentCount=(Get-ChildItem -path $path).Count
        if($parentCount -gt $threshold){
            if((($parentCount /$maxLimit) * 100 ) -gt $importanceThreshold){
                $Alert="Critical"
                #$importance="High"
                $mail+="<span class='highlight'><b>$path</b> : $($parentCount.toString("N0")) > Above ${importanceThreshold}%</span> <br/>"
                #continue
            }
            else{
            $mail+= "<b>$path</b> : $($parentCount.toString("N0")) <br/>"
            }
        }
        if($parentCount -gt 10000){
            $info+="<b>$path</b> : $($parentCount.toString("N0")) <br/>"
            #"$($_.FullName) : $count`n"
        }    

    Get-ChildItem -Path $path -Recurse -Directory | ForEach-Object {
    if($_.FullName -like "*Backup*"){
        continue
    }
    $count = (Get-ChildItem $_.FullName ).count

    #$info for testing purpose

    if($count -gt $threshold){
        if((($count /$maxLimit) * 100 ) -gt $importanceThreshold){
            $Alert="Critical"
            #$importance="High"
            $mail+="<span class='highlight'><b>$($_.FullName)</b> : $($count.toString("N0")) > Above ${importanceThreshold}%</span> <br/>"
            #continue
        }
        else{
        $mail+= "<b>$($_.FullName)</b> : $($count.toString("N0")) <br/>"
        }
    }
    if($count -gt 60000){
        $info+="<b>$($_.FullName)</b> : $($count.toString("N0")) <br/>"
        #"$($_.FullName) : $count`n"
    }

}
}
$mail 
$info
#setting mail props

$smtpServer = ""
$smtpPort = ""
$from = ""
$to = @()
$cc=@()
$subject = "$Alert : PureStorage Filelimit exceed $($threshold/1000)K"

#mail Body

function GenerateBody ($data, $threshold) {
    $htmlText = @"
<html>
    <head>
        <Style>
            body {
                font-family: Calibri, Arial, sans-serif;
                font-size: 14px;
                line-height:1;
              }
            .highlight {
              background-color: yellow;
            }
        </style>
    </head>
    <body>
        <p>Hi Team,<br/>
        <br/>
        File count in Pure Storage limit is 100K, but below Folder(s) are exceeding the threshold limit $($threshold/1000)K<br/>
        Please do some houseKeeping ASAP</P>
        <p>
        $data
        </p>
        <br/>
        <p>Regards,<br/>
        <b>System Notifier </b></p>
    </body>
</html>

"@
    return $htmlText
}
#sending mail if exceeds the threshold
if($mail){
$body=GenerateBody $mail $threshold
Send-MailMessage -SmtpServer $smtpServer `
                 -Port $smtpPort `
                 -From $from `
                 -To $to `
                 -cc $cc `
                 -Subject $subject `
                 -Body $body -BodyAsHtml -Priority $importance
                 }
#only for testing
elseif($info){
$body=GenerateBody $info $threshold
Send-MailMessage -SmtpServer $smtpServer `
                 -Port $smtpPort `
                 -From $from `
                 -To " `
                 -Subject $subject `
                 -Body $body -BodyAsHtml -Priority $importance
                 }