/interface ethernet
set [ find default-name=ether1 ] name=ether2
set [ find default-name=ether2 ] disable-running-check=no name=ether7
set [ find default-name=ether3 ] advertise="" disable-running-check=no name=ether8
set [ find default-name=ether4 ] disable-running-check=no mtu=9216 name=ether9
set [ find default-name=ether5 ] disable-running-check=no name=ether10
/interface vlan
add interface=ether7 name=300_VLAN vlan-id=300
add interface=ether7 mtu=9000 name=1412 vlan-id=1412
add interface=ether10 name=INT_101 vlan-id=101
add interface=ether10 name=IX_201 vlan-id=201
add interface=ether10 name=VLAN200 vlan-id=200
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/ip firewall connection tracking
set udp-timeout=10s
/interface ovpn-server server
add mac-address=FE:8C:60:07:26:10 name=ovpn-server1
/ip address
add address=10.91.91.54/24 interface=300_VLAN network=10.91.91.0
add address=192.168.58.1/30 interface=1412 network=192.168.58.0
add address=10.101.101.2/30 interface=INT_101 network=10.101.101.0
add address=10.201.201.2/30 interface=IX_201 network=10.201.201.0
add address=192.168.10.3/24 interface=VLAN200 network=192.168.10.0
/ip dhcp-client
# Interface not active
add interface=*1
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=10.91.91.1 routing-table=main suppress-hw-offload=no
/system identity
set name=ACCESS_RTR
/system note
set show-at-login=no
/tool bandwidth-server
set authenticate=no
