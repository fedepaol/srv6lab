# Feature Specification: L2 EVPN VXLAN Overlay Between PEs

**Feature Branch**: `003-l2-evpn-overlay`  
**Created**: 2026-04-23  
**Status**: Draft  
**Input**: User description: "L2 EVPN overlay between PE1, PE2, PE3 using VXLAN, following the evpnlab L2 pattern but without L3 EVPN (SRv6 handles L3). Bridge ports with IPs on same subnet across all PEs. Ping between bridge ports (L2), ping from bridge port to remote PE loopback."

## Clarifications

### Session 2026-04-23

- Q: Should bridge (br10) be in VRF red for L3 reachability via SRv6, or stay in global table? → A: Bridge in VRF red (no L3VNI). L2 forwarding via VXLAN, L3 reachability via SRv6 VPN. No L3VNI bridge (br100/vni100) needed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - L2 Ping Between PE Bridge Ports (Priority: P1)

An operator deploys the lab and verifies that PE1, PE2, and PE3 share a Layer 2 broadcast domain via EVPN VXLAN. Each PE has a bridge port with an IP address on the same subnet. Pinging between bridge port IPs succeeds, traffic is forwarded as L2 via VXLAN tunnels, and the ARP/neighbor table is populated via EVPN Type-2 routes.

**Why this priority**: L2 connectivity is the core deliverable — proves EVPN VXLAN data plane works between PEs.

**Independent Test**: After deployment, from PE1 ping PE2 and PE3 bridge port IPs. Verify ping succeeds, check that neighbor table shows MAC addresses learned via EVPN (not local ARP), and confirm VXLAN encapsulated traffic on the underlay.

**Acceptance Scenarios**:

1. **Given** a deployed topology with EVPN VXLAN configured, **When** ping is sent from PE1's bridge port IP to PE2's bridge port IP, **Then** ping succeeds with 0% packet loss.
2. **Given** a deployed topology with EVPN VXLAN configured, **When** ping is sent from PE1's bridge port IP to PE3's bridge port IP, **Then** ping succeeds with 0% packet loss.
3. **Given** the setup script has completed (including initial pings to seed neighbor tables), **When** the operator checks the neighbor table on PE1, **Then** entries for PE2 and PE3 bridge port MACs are present, learned via EVPN.
4. **Given** the setup has completed, **When** the operator inspects BGP EVPN routes, **Then** Type-2 MAC/IP routes for all three PEs' bridge ports are visible.

---

### User Story 2 - Ping from Bridge Port to RemotePE VRF Loopback (Priority: P2)

An operator verifies that from a bridge port on any PE, they can ping the VRF loopback on the RemotePE node. This validates that bridge port IPs are advertised into the SRv6 VRF (via BGP network statement) so return traffic routes correctly through the SRv6 overlay.

**Why this priority**: Validates integration between L2 EVPN overlay and SRv6 L3VPN — bridge port subnets must be reachable from RemotePE's VRF for end-to-end connectivity.

**Independent Test**: From PE1, ping RemotePE's VRF loopback using the bridge port as the source interface. Verify reply returns via the SRv6 path.

**Acceptance Scenarios**:

1. **Given** a deployed topology, **When** ping is sent from PE1's bridge port (source IP) to RemotePE's VRF loopback, **Then** ping succeeds.
2. **Given** a deployed topology, **When** ping is sent from PE2's bridge port (source IP) to RemotePE's VRF loopback, **Then** ping succeeds.
3. **Given** a deployed topology, **When** ping is sent from PE3's bridge port (source IP) to RemotePE's VRF loopback, **Then** ping succeeds.

---

### User Story 3 - EVPN Route Reflector for L2VPN (Priority: P1)

The TOR node acting as BGP route reflector distributes L2VPN EVPN routes (in addition to existing IPv4/IPv6 VPN routes) between all PEs. PEs peer with TOR for the l2vpn evpn address family.

**Why this priority**: Without the route reflector distributing L2VPN EVPN routes, PEs cannot discover each other's VXLAN endpoints and MAC/IP bindings.

**Independent Test**: Check BGP summary on TOR for l2vpn evpn address family. Verify all PE neighbors are active and routes are being reflected.

**Acceptance Scenarios**:

1. **Given** a deployed topology, **When** the operator checks BGP l2vpn evpn summary on TOR, **Then** PE1, PE2, and PE3 are listed as active neighbors.
2. **Given** a deployed topology, **When** the operator checks BGP l2vpn evpn routes on any PE, **Then** Type-2 and Type-3 routes from other PEs are received via TOR.

---

### Edge Cases

- What happens when one PE is restarted — do EVPN routes reconverge and L2 connectivity restore?
- What happens if VXLAN tunnel endpoint (loopback) becomes unreachable via ISIS — does L2 forwarding fail gracefully?
- What happens when two PEs have the same MAC on the bridge — is there a MAC conflict detected?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each PE (PE1, PE2, PE3) MUST have a Linux bridge created for the L2 EVPN domain.
- **FR-002**: Each PE MUST have a VXLAN interface with a consistent VNI (same VNI across all PEs), using the PE's IPv4 loopback as the local VTEP address.
- **FR-003**: The VXLAN interface MUST be enslaved to the bridge on each PE.
- **FR-004**: Each PE MUST have a port on the bridge with an IP address from a shared subnet (same /24 across all PEs, unique host address per PE).
- **FR-005**: The bridge MUST be in VRF red for L3 reachability via SRv6. No L3VNI bridge (br100/vni100) is needed — inter-subnet routing is handled by SRv6, not L3 EVPN.
- **FR-006**: VXLAN interfaces MUST use `nolearning` mode — MAC learning is handled by EVPN control plane, not data plane flooding.
- **FR-007**: VXLAN interfaces MUST have `neigh_suppress on` to enable proxy ARP/ND via EVPN.
- **FR-008**: FRR on each PE MUST have the `l2vpn evpn` address family enabled in the global BGP instance, with the route reflector (TOR) neighbor activated.
- **FR-009**: FRR on each PE MUST advertise all VNIs (`advertise-all-vni`) in the l2vpn evpn address family.
- **FR-010**: TOR (route reflector) MUST have the `l2vpn evpn` address family enabled and MUST reflect L2VPN EVPN routes to all PE clients.
- **FR-011**: Ping between any two PEs' bridge port IPs MUST succeed with L2 forwarding via VXLAN.
- **FR-012**: The neighbor/ARP table on each PE MUST be populated with remote PEs' bridge port MAC/IP entries learned via EVPN.
- **FR-013**: Ping from any PE's bridge port (as source) to another PE's loopback address MUST succeed.
- **FR-014**: Existing SRv6 L3VPN functionality MUST NOT be affected by the addition of L2 EVPN.
- **FR-015**: The setup process MUST include initial pings from each PE's bridge port to all other PEs' bridge ports to seed the neighbor/ARP tables and trigger EVPN Type-2 route generation (silent host workaround).
- **FR-016**: The bridge port subnet MUST be advertised into the SRv6 VRF via a BGP `network` statement on each PE, so that RemotePE learns the route and return traffic is routable through the SRv6 overlay.

### Key Entities

- **Bridge (br10)**: Linux bridge on each PE providing the L2 domain for the EVPN overlay. Carries a local port with an IP address.
- **VXLAN Interface (vni110)**: VXLAN tunnel interface on each PE, identified by VNI, enslaved to the bridge. Uses PE loopback as VTEP source.
- **Bridge Port**: The bridge interface itself (or attached interface) carrying an IP address in the shared L2 subnet. Used for reachability testing.
- **TOR Route Reflector**: Existing TOR node extended with l2vpn evpn address family to reflect EVPN Type-2/Type-3 routes between PEs.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Ping between all PE bridge port IP pairs (PE1↔PE2, PE1↔PE3, PE2↔PE3) succeeds with 0% packet loss.
- **SC-002**: Neighbor/ARP tables on each PE contain entries for the other two PEs' bridge port MACs, learned via EVPN (not manual/static).
- **SC-003**: BGP EVPN route table on each PE shows Type-2 (MAC/IP) routes for all three PEs' bridge ports.
- **SC-004**: BGP EVPN route table on each PE shows Type-3 (Inclusive Multicast) routes for the VXLAN VNI.
- **SC-005**: Ping from any PE's bridge port to RemotePE's VRF loopback succeeds.
- **SC-006**: Existing SRv6 VRF-to-VRF connectivity (PE↔RemotePE) continues to work after L2 EVPN is added.

## Assumptions

- The three PEs' IPv4 loopbacks (10.0.0.1, 10.0.0.2, 10.0.0.3) are reachable between PEs via the ISIS underlay and can serve as VTEP source addresses for VXLAN.
- VNI 110 is used for the L2 domain (consistent with the evpnlab reference pattern).
- The shared bridge port subnet is 192.168.10.0/24: PE1 gets .1, PE2 gets .2, PE3 gets .3.
- VXLAN uses UDP destination port 4789 (standard).
- The TOR route reflector currently peers with PEs for ipv4/ipv6 vpn — adding l2vpn evpn to the same peer-group extends existing peering.
- Bridge is in VRF red for L3 routing via SRv6. No L3VNI (br100/vni100) pattern is used — SRv6 handles inter-subnet routing.
- The bridge port IP is assigned directly to the bridge interface (ip addr add on br10), not via a separate veth pair.
- FRR version 10.6.0 (currently used) supports l2vpn evpn address family with VXLAN.
- Silent host problem is expected and acceptable — EVPN Type-2 MAC/IP routes only appear after initial traffic. The setup script handles this by performing seed pings.
