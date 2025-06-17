/interface ethernet
set [ find default-name=sfp-sfpplus1 ] comment=LALMATIA_SW l2mtu=1500
/interface vlan
add interface=sfp-sfpplus1 mtu=1496 name=VLAN100_VTEP_MGMT vlan-id=100
add interface=sfp-sfpplus1 mtu=1496 name=VLAN101_INT vlan-id=101
add interface=sfp-sfpplus1 mtu=1496 name=VLAN200 vlan-id=200
add interface=sfp-sfpplus1 mtu=1496 name=VLAN201_IX vlan-id=201
/port
set 0 name=serial0
/routing ospf instance
add disabled=no name=ospf-instance-64515 router-id=10.1.1.10
/routing ospf area
add disabled=no instance=ospf-instance-64515 name=ospf-area-64515
/ip address
add address=59.153.100.85/27 interface=ether1 network=59.153.100.64
add address=10.101.101.1/30 interface=VLAN101_INT network=10.101.101.0
add address=10.201.201.1/30 interface=VLAN201_IX network=10.201.201.0
add address=10.10.10.21/30 interface=VLAN100_VTEP_MGMT network=10.10.10.20
add address=10.1.1.10 interface=lo network=10.1.1.10
add address=192.168.10.1/24 interface=VLAN200 network=192.168.10.0
/ip dhcp-client
add comment=defconf interface=*13
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=59.153.100.65 routing-table=main suppress-hw-offload=no
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing ospf interface-template
add area=ospf-area-64515 disabled=no interfaces=VLAN100_VTEP_MGMT networks=10.10.10.20/30 type=ptp
/system identity
set name=CORE_RTR
/system note
set show-at-login=no
/system routerboard settings
set enter-setup-on=delete-key
