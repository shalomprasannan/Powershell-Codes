$a={query user|ConvertFrom-String| foreach{
    if($_.p1){
        $_.p1.replace(">","")
    }
    else{
        $_.p2
    }
}|ConvertFrom-Csv}

Invoke-Command -ComputerName mercury102.m1.local -scriptblock  $a