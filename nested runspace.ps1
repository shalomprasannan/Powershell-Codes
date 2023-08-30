$output=""
$nested_output=""

$list=New-Object System.Collections.ArrayList

$script={
    param($runspacePool,$list)
    $scr={
        start-sleep -Seconds 30
        get-service}
    $new_runspace = [PowerShell]::Create()
    $new_runspace.AddScript($scr)
    $new_runspace.runspacePool=$runspacePool
    $job=$new_runspace.beginInvoke()
    $list.Add([pscustomobject]@{
        nest="in"
        powershell=$new_runspace
        job=$job
    })
}


$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
#$runspacepool.setMaxRunspaces(10)
$runspacePool.Open()
$runspace = [PowerShell]::Create()
$runspace.AddScript($script).AddArgument($runspacepool).AddArgument($list)
$runspace.runspacePool=$runspacePool
$job=$runspace.BeginInvoke()
$list.Add([pscustomobject]@{
nest="out"
Job=$job
powershell=$runspace})

###_-----_

$output=$runspace.EndInvoke($job)
$nested_output=$output[1].runs.EndInvoke($output[1].job)
$runspace

$Flag = 'static','nonpublic','instance'
$_worker=$output[1].runs.GetType().getfield('worker',$flag)

$Worker = $_Worker.GetValue($output[1].runs)
$_CRP = $worker.GetType().GetProperty('CurrentlyRunningPipeline',$Flag)
$CRP = $_CRP.GetValue($Worker)
$CRP