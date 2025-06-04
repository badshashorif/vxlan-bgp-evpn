
````markdown
# VXLAN EVPN Troubleshooting Lab (NX-OS + MikroTik CORE)

## 🧠 Project Overview

This lab simulates a VXLAN EVPN environment using Cisco NX-OS VTEPs and MikroTik core routers. The goal is to validate L2 connectivity over VXLAN across distributed access points and understand how to troubleshoot common VXLAN issues.

## 🗺️ Lab Topology

- **NXOS2 (VTEP-1)** ↔ **NXOS3** ↔ **NXOS4** ↔ **NXOS5 (VTEP-2)**
- **MikroTik CORE Router** is connected to NXOS2
- **Access Router** is connected to NXOS5
- OSPF runs between all NX-OS nodes for underlay routing
- BGP EVPN is used for overlay MAC/IP advertisement
- VLANs 101 and 201 map to VNIs 10101 and 20101

## ✅ Key Config Highlights

- VTEPs: NXOS2 and NXOS5
- Loopback1 is the NVE source interface
- BGP EVPN with full mesh peering (no route reflector)
- NVE1 interfaces with `ingress-replication protocol bgp`
- VNIs are enabled with `vn-segment` under VLAN
- No VRF used — plain L2VNI bridging only

---

## 🛠️ VXLAN Troubleshooting Guide

Troubleshooting VXLAN can be broken down into underlay (IP), overlay (BGP EVPN), and data-plane checks.

---

### 🔍 1. **Underlay OSPF Reachability**

Ensure all Loopback0 IPs are reachable between VTEPs.

```bash
# Ping from NXOS2 to NXOS5
ping 10.1.1.4 source 10.1.1.1 vrf default
````

✅ *Expected:* All Loopback0 IPs should respond — OSPF adjacency must be up.

---

### 🔍 2. **BGP EVPN Status Check**

```bash
# View BGP EVPN neighbors
show bgp l2vpn evpn summary

# Detailed neighbor status
show bgp l2vpn evpn neighbors 10.1.1.4
```

✅ *Expected:* All VTEPs should show `Established`.

🛑 *If not:*

* Check `update-source loopback0`
* Check that loopback IPs are reachable
* Ensure correct ASN and remote-as values

---

### 🔍 3. **NVE Interface Health**

```bash
# Check NVE state
show nve interface

# Detailed VXLAN state
show nve peers
```

✅ *Expected:*

* `NVE1` should be `Up`
* Peer IPs should appear with `UP` status
* Type should show `BGP` (not static or dynamic)

🛑 *If not:*

* Check `host-reachability protocol bgp` under `interface nve1`
* Verify `source-interface loopback1`
* Ensure Loopback1 IPs are reachable

---

### 🔍 4. **VNI and VLAN Mapping**

```bash
# Check VLAN to VNI binding
show vlan id 101
show nve vni

# MAC learning status in VXLAN
show mac address-table | include 10101
```

✅ *Expected:*

* `VLAN 101` should show `vn-segment 10101`
* `nve vni` should show state `Up`
* MACs should be learned for each remote endpoint

🛑 *If not:*

* Ensure `vn-segment` command exists under VLAN
* Check both VTEPs have same VLAN/VNI mapping
* Ensure endpoint traffic is generating ARP/MAC entries

---

### 🔍 5. **Packet Path Debug (Advanced)**

```bash
# Check VXLAN encaps/decaps
show forwarding vxlan counters
show interface nve1

# Check EVPN routes
show bgp l2vpn evpn route-type 2

# Check ARP suppression
show ip arp summary
```

---

## 📌 Common Pitfalls

| Issue                 | Check                                             |
| --------------------- | ------------------------------------------------- |
| NVE tunnel down       | Loopback1 not reachable or BGP EVPN not up        |
| MACs not learned      | VLAN/VNI not mapped or trunk misconfigured        |
| No BGP neighbors      | Loopback0 unreachable or `update-source` misused  |
| Ping fails over VXLAN | NVE down, BGP down, or L2 flood domain misaligned |

---

## 📂 Directory Structure

```
📁 vxlan-evpn-lab/
├── README.md
├── configs/
│   ├── NXOS2.cfg
│   ├── NXOS3.cfg
│   ├── NXOS4.cfg
│   ├── NXOS5.cfg
│   └── CORE_ROUTER.txt (optional)
|   └── ACCESS_ROUTER.txt (optional)
├── vxlan-lab.png

```

---

## 📚 References

* Cisco VXLAN EVPN Configuration Guide
* NX-OS `show nve`, `show bgp l2vpn evpn` docs
* MikroTik RouterOS bridging docs

```

---

Let me know if you want the exact GitHub `repo-template` exported with your configs and the image you uploaded — I can zip and structure it for you.
```
