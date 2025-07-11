# Cisco VXLAN Switch Port Configuration with LACP and L2 Connectivity

This repository contains Cisco VXLAN switch interface configurations with detailed explanations for:

- VXLAN switch to L2 access switch trunking
- Underlay routed interfaces using OSPF and PIM
- VXLAN to VXLAN inter-switch connectivity via LACP
- L2 switch uplinks using LACP trunk

## 🔹 VXLAN Switch to L2 Access Switch (Single Trunk Link)
```cisco
interface Ethernet1/10
  description Access-Switch-Trunk
  switchport mode trunk
  switchport trunk allowed vlan 2310-2315
  spanning-tree bpduguard enable
  spanning-tree guard root
  spanning-tree bpdufilter enable
  logging event port link-status
  no shutdown
```

## 🔹 VXLAN Underlay Routed Link (P2P, OSPF)
```cisco
interface Ethernet1/59
  description Underlay-P2P-Uplink
  no switchport
  mtu 9200
  ip address 10.19.4.41/30
  ip ospf network point-to-point
  ip router ospf 10 area 0.0.0.0
  ip pim sparse-mode
  no shutdown
```

## 🔹 VXLAN-to-VXLAN Switch Link: Routed LACP Port-Channel
```cisco
interface port-channel21
  description VXLAN-Fabric-Link
  no switchport
  mtu 9200
  ip address 10.19.4.9/30
  ip ospf network point-to-point
  ip router ospf 10 area 0.0.0.0
  ip pim sparse-mode

interface Ethernet1/56
  description Fabric-Uplink-1
  no switchport
  mtu 9200
  channel-group 21 mode active
  no shutdown

interface Ethernet1/63
  description Fabric-Uplink-2
  no switchport
  mtu 9200
  channel-group 21 mode active
  no shutdown
```

## 🔹 VXLAN to Access Switch (LACP Trunk Port-Channel)
```cisco
interface port-channel5
  description Access-Switch-LACP-Trunk
  switchport mode trunk
  switchport trunk allowed vlan 2801-2805
  spanning-tree bpdufilter enable

interface Ethernet1/35
  description Access-Port1
  switchport mode trunk
  switchport trunk allowed vlan 2801-2805
  channel-group 5 mode active
  spanning-tree bpdufilter enable

interface Ethernet1/36
  description Access-Port2
  switchport mode trunk
  switchport trunk allowed vlan 2801-2805
  channel-group 5 mode active
  spanning-tree bpdufilter enable
```

## 📌 Best Practices
| Feature             | Recommendation                                  |
|---------------------|-------------------------------------------------|
| MTU                 | Always set to 9200+ for VXLAN                   |
| OSPF & PIM          | Required in routed underlay for EVPN VXLAN     |
| BPDU Guard          | Enable on access-facing ports                   |
| BPDU Filter         | Use carefully; disable only if loop-safe       |
| Port-Channel (LACP) | Use `mode active` for redundancy & efficiency  |

## 📁 Repository Structure
```
vxlan-config/
├── README.md
└── config/
    ├── vxlan-switch-01.txt
    └── vxlan-switch-02.txt
```
