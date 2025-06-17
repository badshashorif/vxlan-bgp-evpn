
# VXLAN EVPN Lab Topology

This project demonstrates a VXLAN EVPN fabric using Cisco Nexus switches and MikroTik routers for access and core.

## Components
- Nexus VTEPs (LALMATIA, BOROBAGH, GREEN ROAD, COLO CITY)
- MikroTik CORE and ACCESS Routers
- Underlay: OSPF
- Overlay: iBGP EVPN
- VXLAN Mode: Ingress Replication (BGP)
- Multicast: PIM with Anycast RP

## Topology Overview
```
MikroTik (CORE_RTR)
       |
   LALMATIA (VTEP_1)
  /               \
BOROBAGH        GREEN ROAD
  \               /
   COLO CITY (VTEP_4)
       |
   MikroTik (ACCESS_RTR)
```
