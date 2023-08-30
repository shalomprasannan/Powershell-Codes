#gets edgename, poolname, members in each pool
foreach ($edge in $edges) {
    $lbs=Get-NsxLoadBalancer -Edge $edge 
    #$lbs | select edgeId,VirtualServer
    
    foreach($lb in $lbs){
        $pools=Get-NsxLoadBalancerPool -LoadBalancer $lbs
        $pools|select edgeId,name,@{l="members";e={$_.member.count}}
    }
}

#gets pool counts on each edge
foreach ($edge in $edges) {
    Get-NsxLoadBalancer -Edge $edge | select edgeid,@{l="count";e={($_.pool).count}}
}

#gets count of virtual server on each edge
foreach ($edge in $edges) {
    Get-NsxLoadBalancer -Edge $edge | select edgeid,@{l="count";e={($_.virtualserver).count}}
}
