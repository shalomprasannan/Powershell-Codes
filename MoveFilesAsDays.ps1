#$file = "\\pure02_nas\bcc_system\signature"


#Get-ChildItem -Path "\\pure02_nas\bcc_system\signature\" -File | 
#Move-Item -Destination "\\pure02_nas\bcc_system\signature\movedFiles\" -Force

$sourceFolder = "\\pure02_nas\bcc_system\signature\"
$destinationFolder = "\\pure02_nas\bcc_system\signature\MovedFiles\"

# Get all files in the source folder
$files = Get-ChildItem -Path $sourceFolder -File

# Loop through each file and move it to its corresponding monthly folder
foreach ($file in $files) {
    # Get the month and year of the file creation time
    $Day = $file.CreationTime.Day
    $month = $file.CreationTime.Month
    $year = $file.CreationTime.Year
    
    # Create the monthly folder if it doesn't already exist
    $monthlyFolder = Join-Path -Path $destinationFolder -ChildPath "$Day-$month-$Year"
    if (!(Test-Path -Path $monthlyFolder -PathType Container)) {
        New-Item -ItemType Directory -Path $monthlyFolder | Out-Null
    }
    
    # Move the file to the monthly folder
    $fileDestination = Join-Path -Path $monthlyFolder -ChildPath $file.Name
    Move-Item -Path $file.FullName -Destination $fileDestination
}
