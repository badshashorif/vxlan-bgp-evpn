 Ei project-e apnar **VXLAN-based L2 bridging + L3 routing (Type-2/3)** topology explain korchi step-by-step with configuration logic:

---

## 🔧 **Topology Summary**

* **Protocol:** OSPF + iBGP (ASN 134732)
* **VXLAN VTEPs:** NXOS2, NXOS3, NXOS4, NXOS5
* **Routing Loopbacks (VTEP):** `10.1.1.x`
* **VXLAN Loopbacks (NVE):** `10.2.2.x`
* **Access/Core Router (MikroTik):**

  * VLAN 101 = Internet
  * VLAN 201 = BDIX/IX
* **Objective:** L2 extension via VXLAN; L3 routing handled by core via iBGP.

---

## 🧱 **1. Core Router (MikroTik) Config**

* **Purpose:** Loopback: `10.1.1.10`, uplink to NXOS2
* Adds VLAN interfaces for Internet (101) and IX (201)
* Redistributes OSPF routes into BGP (ASN 134732)

➡️ Sample config (from ZIP):

```plaintext
/interface vlan
add name=Internet101 vlan-id=101 interface=ether4
add name=IX201 vlan-id=201 interface=ether4

/ip address
add address=10.101.101.1/30 interface=Internet101
add address=10.201.201.1/30 interface=IX201
add address=10.1.1.10/32 interface=loopback

/routing ospf instance
add name=default router-id=10.1.1.10

/routing ospf interface
add interface=loopback network-type=point-to-point
add interface=ether4 network-type=broadcast

/routing bgp instance
add as=134732 router-id=10.1.1.10

/routing bgp peer
add name=nxos2 remote-address=10.1.1.1 remote-as=134732
```

---

## 🔄 **2. NXOS VTEP Switches (NXOS2–NXOS5)**

### Key Components:

* **OSPF:** Internal routing for loopback reachability
* **BGP:** iBGP peering for VXLAN EVPN
* **NVE:** VXLAN Network Virtualization Edge interface
* **VLAN-to-VNI Mapping:** Maps VLAN 101 & 201 to VNIs 10101 and 20201
* **L2VNI:** Bridges layer 2
* **L3VNI:** Handles routing via L3 gateway

➡️ Sample Config Highlights for NXOS2:

```bash
interface loopback0
 ip address 10.1.1.1/32

interface loopback1
 ip address 10.2.2.1/32

router ospf 1
 router-id 10.1.1.1
 network 10.0.0.0 0.255.255.255 area 0

router bgp 134732
 router-id 10.1.1.1
 address-family l2vpn evpn
  neighbor 10.1.1.2 activate
  neighbor 10.1.1.3 activate
  neighbor 10.1.1.4 activate
  neighbor 10.1.1.10 activate

vlan 101
 name Internet
vlan 201
 name IX

interface nve1
 no shutdown
 source-interface loopback1
 member vni 10101
  ingress-replication protocol bgp
 member vni 20201
  ingress-replication protocol bgp
```

📝 Each NXOS config includes:

* Loopback0 and Loopback1 setup
* OSPF + BGP config
* NVE1 VXLAN config
* VNI ↔ VLAN mapping
* BGP EVPN for MAC/IP advertisement

---

## 🌐 **3. Access Router (MikroTik)**

* Connected to NXOS5
* VLAN 101 & 201 are trunked
* Loopback: `10.1.1.11`

➡️ Sample config:

```plaintext
/interface vlan
add name=Internet101 vlan-id=101 interface=ether4
add name=IX201 vlan-id=201 interface=ether4

/ip address
add address=10.101.101.2/30 interface=Internet101
add address=10.201.201.2/30 interface=IX201
add address=10.1.1.11/32 interface=loopback

/routing ospf instance
add name=default router-id=10.1.1.11

/routing bgp instance
add as=134732 router-id=10.1.1.11

/routing bgp peer
add name=nxos5 remote-address=10.1.1.4 remote-as=134732
```

---

## 📁 **What's Inside the ZIP**

| File Name           | Description                        |
| ------------------- | ---------------------------------- |
| `core_router.rsc`   | MikroTik core config               |
| `access_router.rsc` | MikroTik access config             |
| `nxos2_config.txt`  | VXLAN + OSPF + iBGP config (NXOS2) |
| `nxos3_config.txt`  | VXLAN + OSPF + iBGP config (NXOS3) |
| `nxos4_config.txt`  | VXLAN + OSPF + iBGP config (NXOS4) |
| `nxos5_config.txt`  | VXLAN + OSPF + iBGP config (NXOS5) |

---

## ✅ **Next Steps**

1. Apply MikroTik configs via Winbox CLI or `.rsc` import
2. Apply NXOS configs on each VTEP device
3. Ensure all loopbacks are reachable via OSPF
4. Verify iBGP EVPN neighborships
5. Test VXLAN bridging for VLAN 101 & 201

---





🔍 VXLAN EVPN fabric troubleshooting steps!

---

## 🧩 1. **Check NVE Interface Status**

```bash
show nve interface
```

**Expected output:**

* `Interface: nve1`
* `State: Up`
* `Source-Interface: loopback1`

👉 Jodi **state down** hoy:

* Loopback interface up ase?
* IP assigned ase?
* BGP e peerings thikmoto ase?

---

## 🧩 2. **Check NVE Peering / VTEP Neighbors**

```bash
show nve peers
```

**Expected output:**

* Remote VTEP IPs
* VNI info
* `Up` status

👉 Jodi peer dekhay na:

* BGP EVPN thik ase?
* Overlay e loopback IP use kora hocche?

---

## 🧩 3. **Check VNIs Mapped Properly**

```bash
show nve vni
```

**Expected:**

* Each VLAN mapped to correct VNI
* VNI state should be `Up`

Also:

```bash
show vlan
show vlan brief
```

---

## 🧩 4. **Check EVPN Routes (MAC & VNI Learning)**

```bash
show bgp l2vpn evpn
```

Or to check MAC/VTEP for specific VNI:

```bash
show bgp l2vpn evpn vni <VNI>
```

Check specific MAC:

```bash
show bgp l2vpn evpn mac <mac-address>
```

Check local + remote MAC learning:

```bash
show mac address-table
```

---

## 🧩 5. **Check OSPF Status**

```bash
show ip ospf neighbor
show ip ospf interface brief
```

👉 Ensure all underlay links are OSPF-neighbored.

---

## 🧩 6. **Check BGP EVPN Peering**

```bash
show bgp l2vpn evpn summary
```

Check state = `Established`.

Also:

```bash
show bgp l2vpn evpn neighbors <neighbor-IP> advertised-routes
show bgp l2vpn evpn neighbors <neighbor-IP> received-routes
```

---

## 🧩 7. **Ping Underlay & Overlay**

Underlay connectivity:

```bash
ping <underlay IP> vrf default
```

Overlay connectivity (VTEP-to-VTEP):

```bash
ping <loopback1 IP>
```

VXLAN data plane test:

```bash
ping nve peer-ip <VTEP IP> vni <VNI>
```

---

## 🧩 8. **Check Interface Status**

```bash
show interface brief
show interface Ethernet1/x
```

---

## 🧩 9. **Traceroute & Path Visibility**

Check data path:

```bash
traceroute <remote host IP>
```

---

## 🧩 10. **Debug Commands (if needed)**

🔴 Use in lab only:

```bash
debug nve all
debug bgp l2vpn evpn
debug ospf adj
```

---

## 🔧 Bonus: Packet Flow Observation

If MAC not learning properly:

* Check ARP:

  ```bash
  show ip arp
  ```
* Ensure `suppress-arp` not blocking wrong behavior

---

## 🧠 Pro Tips:

| Checkpoint         | Command                       | Purpose                          |
| ------------------ | ----------------------------- | -------------------------------- |
| NVE status         | `show nve interface`          | Tunnel up? Source interface set? |
| Peers              | `show nve peers`              | Overlay working?                 |
| VNI state          | `show nve vni`                | Are VNIs mapped and up?          |
| BGP EVPN           | `show bgp l2vpn evpn summary` | BGP session up?                  |
| MAC learning       | `show mac address-table`      | Local + remote MAC entries?      |
| VTEP communication | `ping nve peer-ip`            | VXLAN data plane check           |
| Underlay routing   | `show ip ospf neighbor`       | OSPF underlay functional?        |

---

