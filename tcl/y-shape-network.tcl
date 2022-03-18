#网络的自定义参数
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
set val(rp) DSR    ;#若使用AODV会Segment fault内存溢出
set val(x) 1000   ;#模拟场景大小
set val(y) 1000


#初始化全局变量
set ns [new Simulator]
#打开 Trace 文件
set namfd [open ns1.nam w]
$ns namtrace-all-wireless $namfd $val(x) $val(y)
set tracefd [open $val(tr) w]
$ns trace-all $tracefd
#建立一个拓扑对象，以记录移动节点在拓扑内移动的情况
set topo [new Topography]
#拓扑范围为 1000m*1000m
$topo load_flatgrid $val(x) $val(y)
#创建物理信道对象
set chan [new $val(chan)]
#创建 God 对象
set god [create-god $val(nn)]
#节点属性
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

#节点位置设置
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

#新建一个 UDP Agent 并把它绑定到初始节点上
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
##新建一个 CBR 流量发生器，设定分组大小为 500Byte，发送间隔为 5ms
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.05
$cbr0 attach-agent $udp0
#在汇聚节点建立一个数据接受器
set null0 [new Agent/Null]
$ns attach-agent $n7 $null0
#连接初始节点和汇聚节点的Agent
$ns connect $udp0 $null0
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

set sink0 [new Agent/LossMonitor]
$ns attach-agent $n4 $sink0

#定义节点模拟的结束时间
for {set i 0 } {$i<$val(nn)} {incr i} {
    $ns at $val(stop) "$node_($i) reset";
}
$ns at $val(stop) "stop"
$ns at $val(stop) "puts \"NS EXITING...\"; $ns halt"
#stop 函数
proc stop {} {
    global ns tracefd namfd
    $ns flush-trace
    close $tracefd
    close $namfd
    exec nam ns1.nam &
}
$ns run
