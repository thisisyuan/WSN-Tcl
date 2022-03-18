#parameters for the network
set val(stop) 100
set val(tr) yshape.tr
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy 
set val(mac) Mac/SMAC                 
set val(ifq) CMUPriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 50
set opt(energymodel)    EnergyModel
set opt(initialenergy)  500           
set val(nn) 8
set val(rp) DSR    ;#use AODV can cause segment fault, dont know why
set val(x) 1000   ;#map size
set val(y) 1000


#Initialize global virables
set ns [new Simulator]
#打开 Trace 文件
set namfd [open ns1.nam w]
$ns namtrace-all-wireless $namfd $val(x) $val(y)
set tracefd [open $val(tr) w]
$ns trace-all $tracefd
#create a topo object, keep track the node movement in the network topology
set topo [new Topography]
#Topology  1000m*1000m
$topo load_flatgrid $val(x) $val(y)
#creat physical channel object
set chan [new $val(chan)]
#Create God object
set god [create-god $val(nn)]
#Node properties
$ns node-config -adhocRouting $val(rp) \
        -llType $val(ll) \
        -macType $val(mac)\
        -ifqType $val(ifq) \
        -ifqLen $val(ifqlen) \
        -antType $val(ant) \
        -propType $val(prop) \
        -phyType $val(netif)\
        -channel $chan \
        -topoInstance $topo \
        -agentTrace ON \
        -routerTrace ON \
        -macTrace ON \
#        -energyModel $opt(energymodel) \
        -idlePower 0.01 \
        -rxPower 1.0 \
        -txPower 1.0 \
        -sleepPower 0.01 \
        -transitionPower 2 \
        -transitionTime 0.05 \
        -initialEnergy $opt(initialenergy) \
        -movementTrace ON
for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns node]
}

#set Node position
set n0 [$ns node]
$n0 set X_ 600
$n0 set Y_ 804
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 695
$n1 set Y_ 704
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 797
$n2 set Y_ 602
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 897
$n3 set Y_ 696
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20
set n4 [$ns node]
$n4 set X_ 1000
$n4 set Y_ 804
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20
set n5 [$ns node]
$n5 set X_ 799
$n5 set Y_ 499
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20
set n6 [$ns node]
$n6 set X_ 799
$n6 set Y_ 401
$n6 set Z_ 0.0
$ns initial_node_pos $n6 20
set n7 [$ns node]
$n7 set X_ 799
$n7 set Y_ 294
$n7 set Z_ 0.0
$ns initial_node_pos $n7 20

#setup a UDP Agent, link the agent to the source node
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
##create CBR traffic generator，set batch size to 500Byte，transmission interval to 5ms
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.05
$cbr0 attach-agent $udp0
#create a receiver at the sink node
set null0 [new Agent/Null]
$ns attach-agent $n7 $null0
#connect the Agents of sink and source 
$ns connect $udp0 $null0
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

set sink0 [new Agent/LossMonitor]
$ns attach-agent $n4 $sink0

# define when simulation ends for each node
for {set i 0 } {$i<$val(nn)} {incr i} {
    $ns at $val(stop) "$node_($i) reset";
}
$ns at $val(stop) "stop"
$ns at $val(stop) "puts \"NS EXITING...\"; $ns halt"
#stop function
proc stop {} {
    global ns tracefd namfd
    $ns flush-trace
    close $tracefd
    close $namfd
    exec nam ns1.nam &
}
$ns run
