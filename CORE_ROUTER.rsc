/interface vlan
add name=ACCESS_RTR_INT vlan-id=101 interface=ether4
add name=ACCESS_RTR_IX vlan-id=201 interface=ether4

/ip address
add address=10.101.101.10/30 interface=ACCESS_RTR_INT
add address=10.201.201.10/30 interface=ACCESS_RTR_IX
add address=10.1.1.10/32 interface=loopback

/routing ospf instance
set [ find default=yes ] router-id=10.1.1.10

/routing ospf interface
add interface=ACCESS_RTR_INT network-type=point-to-point
add interface=ACCESS_RTR_IX network-type=point-to-point

/routing ospf network
add network=10.101.101.0/30 area=backbone
add network=10.201.201.0/30 area=backbone
add network=10.1.1.10/32 area=backbone