# Research: L2 EVPN VXLAN Overlay

## FRR 10.6.0 l2vpn evpn Support

**Decision**: FRR 10.6.0 fully supports l2vpn evpn address family with VXLAN.
**Rationale**: FRR has supported EVPN with VXLAN since version 7.x. Version 10.6.0 includes mature support for Type-2 (MAC/IP), Type-3 (Inclusive Multicast) routes, `advertise-all-vni`, and route reflection.
**Alternatives considered**: None — FRR is already the routing daemon in use.

## VXLAN with IPv4 VTEP over ISIS Underlay

**Decision**: Use PE IPv4 loopbacks (10.0.0.x) as VTEP source addresses for VXLAN tunnels.
**Rationale**: ISIS distributes IPv4 loopback routes between all PEs (interface has `ip router isis PE`). PEs are L2-adjacent on the shared linux bridge, so VXLAN outer packets are delivered directly. IPv4 VTEP is standard for VXLAN (RFC 7348).
**Alternatives considered**: IPv6 VTEP — possible but adds complexity and less commonly used with VXLAN.

## Bridge in VRF without L3VNI

**Decision**: Place br10 in VRF red (`ip link set br10 master red`) but do NOT create an L3VNI bridge (br100/vni100).
**Rationale**: Bridge in VRF makes bridge port IP participate in SRv6 VPN routing. L3 inter-subnet routing handled by SRv6 (existing), not by EVPN L3VNI. This matches the reference evpnlab pattern minus the L3VNI components. Clarified during spec review.
**Alternatives considered**: Bridge in global table with route leaking — rejected as unnecessarily complex.

## l2vpn evpn on RemotePE

**Decision**: Add l2vpn evpn address family to all PEs including RemotePE in the FRR template.
**Rationale**: Harmless on RemotePE — no local VNIs, so `advertise-all-vni` has nothing to advertise. Simpler than conditional template logic. TOR reflects EVPN routes to all CLIENTS peers; RemotePE ignores them.
**Alternatives considered**: Conditional l2vpn evpn AF — rejected as unnecessary complexity.

## Network Statement for Bridge Subnet

**Decision**: Add `network 192.168.10.0/24` in VRF red's BGP ipv4 unicast AF on PE1/PE2/PE3. Use conditional template variable (`L2EVPN_VRF_NETWORK`) — empty for RemotePE.
**Rationale**: RemotePE needs to learn the bridge subnet route via SRv6 VPN for return traffic. `redistribute connected` alone would advertise it (since br10 is in VRF red), but explicit `network` statement gives control. RemotePE doesn't have the subnet, so must not advertise it.
**Alternatives considered**: Rely solely on `redistribute connected` — would work for PE1/2/3 but we use explicit `network` per user requirement. Actually `redistribute connected` already covers it since br10 is in VRF red. Both work. Using `network` statement as user specified.

## Silent Host and Seed Pings

**Decision**: Add seed pings in global setup.sh after convergence wait.
**Rationale**: EVPN Type-2 routes only generated after local MAC/IP is learned by zebra. Initial ping triggers ARP/neighbor discovery, which populates local bridge FDB, which zebra propagates to BGP as Type-2 routes. Standard EVPN behavior.
**Complementary**: `advertise-svi-ip` is also enabled — proactively advertises bridge (SVI) IP as Type-2 route without waiting for traffic. Helps remote PEs learn bridge port MAC/IP bindings faster. Seed pings still needed to trigger ARP resolution and populate local neighbor tables on each PE.
