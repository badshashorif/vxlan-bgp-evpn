# VXLAN QinQ-Based L2 Extension Between Routers

## 🖥️ Topology Overview

```
RTR01 -- VLAN200,201 -- BDCOM_SW -- VXLAN_SW_01 ==VXLAN Tunnel== VXLAN_SW_02 -- HUAWEI_SW -- RTR02
```

- **VXLAN Switches**: Cisco NX-OS (with `dot1q-tunnel` for QinQ)
- **Intermediate Switches**: BDCOM & HUAWEI (L2 Trunk Switches)
- **Customer VLANs**: 
  - VLAN 200: 10.10.10.0/30
  - VLAN 201: 10.10.10.4/30

## 🧾 VLAN ↔ VXLAN Mapping

| VLAN | VNI     |
|------|---------|
| 200  | 140200  |
| 201  | 140201  |

---

## 🔧 Cisco VXLAN_SW_01 Configuration

```bash
feature telnet
feature ospf
feature bgp
feature pim
feature fabric forwarding
feature interface-vlan
feature vn-segment-vlan-based
feature lacp
feature bfd
feature nv overlay
nv overlay evpn

router ospf 64515
  bfd
  router-id 10.1.1.1
  default-information originate always
  max-metric router-lsa on-startup wait-for bgp 64515
exit

system jumbomtu 9200
errdisable recovery interval 30

ip pim rp-address 10.2.2.1 group-list 224.0.0.0/4
ip pim ssm range 232.0.0.0/8
ip pim anycast-rp 10.2.2.1 10.1.1.1
ip pim anycast-rp 10.2.2.1 10.1.1.2

interface loopback0
  ip address 10.1.1.1/32
  ip router ospf 64515 area 0.0.0.0
  ip pim sparse-mode
exit 
interface loopback1
  ip address 10.2.2.1/32
  ip router ospf 64515 area 0.0.0.0
  ip pim sparse-mode
exit

interface Ethernet1/22
  switchport
  switchport mode dot1q-tunnel
  switchport access vlan 200
  spanning-tree bpdufilter enable

interface Eth1/59
  no switchport
  mtu 9200
  ip address 10.10.10.1/30
  ip ospf network point-to-point
  ip router ospf 64515 area 0.0.0.0
  ip pim sparse-mode
  no shutdown
exit

router bgp 64515
  router-id 10.1.1.1
  address-family ipv4 unicast
  address-family l2vpn evpn
  
  neighbor 10.1.1.2
    remote-as 64515
    update-source loopback0
    address-family ipv4 unicast
      send-community
      send-community extended
      route-reflector-client
      next-hop-self
      soft-reconfiguration inbound always
    address-family l2vpn evpn
      send-community
      send-community extended
      route-reflector-client

vlan 200
  vn-segment 140200
vlan 201
  vn-segment 140201

interface nve1
  no shutdown
  source-interface loopback0
  host-reachability protocol bgp
  member vni 140200
    ingress-replication protocol bgp
  member vni 140201
    ingress-replication protocol bgp
```

---

## 🔧 Cisco VXLAN_SW_02 Configuration

```bash
# Same feature & VLAN/VNI settings as VXLAN_SW_01

feature telnet
feature ospf
feature bgp
feature pim
feature fabric forwarding
feature interface-vlan
feature vn-segment-vlan-based
feature lacp
feature bfd
feature nv overlay
nv overlay evpn

router ospf 64515
  bfd
  router-id 10.1.1.2
  max-metric router-lsa on-startup wait-for bgp 64515
exit

system jumbomtu 9200
errdisable recovery interval 30

ip pim rp-address 10.2.2.2 group-list 224.0.0.0/4
ip pim ssm range 232.0.0.0/8
ip pim anycast-rp 10.2.2.1 10.1.1.1
ip pim anycast-rp 10.2.2.1 10.1.1.2

interface loopback0
  ip address 10.1.1.2/32
  ip router ospf 64515 area 0.0.0.0
  ip pim sparse-mode
exit 
interface loopback1
  ip address 10.2.2.2/32
  ip router ospf 64515 area 0.0.0.0
  ip pim sparse-mode
exit

interface Ethernet1/22
  switchport
  switchport mode dot1q-tunnel
  switchport access vlan 200
  spanning-tree bpdufilter enable

interface Eth1/59
  no switchport
  mtu 9200
  ip address 10.10.10.2/30
  ip ospf network point-to-point
  ip router ospf 64515 area 0.0.0.0
  ip pim sparse-mode
  no shutdown
exit

router bgp 64515
  router-id 10.1.1.2
  address-family ipv4 unicast
  address-family l2vpn evpn
  
  neighbor 10.1.1.1
    remote-as 64515
    update-source loopback0
    address-family ipv4 unicast
      send-community
      send-community extended
      route-reflector-client
      next-hop-self
      soft-reconfiguration inbound always
    address-family l2vpn evpn
      send-community
      send-community extended
      route-reflector-client

vlan 200
  vn-segment 140200
vlan 201
  vn-segment 140201

interface nve1
  no shutdown
  source-interface loopback0
  host-reachability protocol bgp
  member vni 140200
    ingress-replication protocol bgp
  member vni 140201
    ingress-replication protocol bgp
```

---

## 🔧 HUAWEI_SW Configuration (Trunk)

```bash
system-view
vlan batch 200 201

interface Ethernet1/0/1
 port link-type trunk
 port trunk allow-pass vlan 200 201
```

---

## 🔧 BDCOM_SW Configuration (Trunk)

```bash
vlan 200,201
interface ethernet 1/0/1
 switchport mode trunk
 switchport trunk allowed vlan 200,201
```

---

## 🧪 Test

On RTR01:
```
ping 10.10.10.2  # VLAN 200
ping 10.10.10.6  # VLAN 201
```

On RTR02:
```
ping 10.10.10.1  # VLAN 200
ping 10.10.10.5  # VLAN 201
```

---

## ✅ Result

Point-to-point L2 VXLAN achieved using QinQ + Cisco NVE with BDCOM & Huawei as transport.