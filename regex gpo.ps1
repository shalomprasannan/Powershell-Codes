# Set the pattern to match
$pattern = ".*Windows Settings.*Security Settings.*Account Policies.*Password Policy.*Enforce password history.*Domain policy.*"

# Read the contents of the text file
$fileContents = Get-Content "C:\temp\GPOReport.html" -Raw

# Find the match using a regular expression
$regex = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
$match = $regex.Match($fileContents)

# Get the text between the two specified strings
$prefix = "Enforce password history"
$suffix = "Domain policy"
$startIndex = $match.Value.IndexOf($prefix) + $prefix.Length
$endIndex = $match.Value.IndexOf($suffix)

if ($startIndex -lt 0 -or $endIndex -lt 0) {
    Write-Host "Prefix or suffix not found in match value"
} elseif ($startIndex -ge $endIndex) {
    Write-Host "Prefix comes after suffix in match value"
} else {
    $startIndex += $prefix.Length
    $result = $match.Value.Substring($startIndex, $endIndex - $startIndex)
    Write-Host $result
}
