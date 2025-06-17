
# VXLAN EVPN Deployment Steps

1. Configure loopback0 and loopback1 for OSPF and NVE source.
2. Enable OSPF on all links and loopbacks.
3. Configure PIM sparse-mode on all routed links.
4. Setup Anycast RP using loopback1.
5. Establish iBGP EVPN using loopback0.
6. Create VLANs and map to VNIs.
7. Configure NVE interface and add VNI members.
8. Trunk service VLANs to MikroTik routers.
