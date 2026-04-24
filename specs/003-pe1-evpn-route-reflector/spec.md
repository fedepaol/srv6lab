# Feature Specification: PE1 as EVPN Route Reflector

**Feature Branch**: `004-pe1-evpn-route-reflector`  
**Created**: 2026-04-24  
**Status**: Draft  
**Input**: User description: "PE1 acts as route reflector for EVPN routes instead of TOR. All other PEs (PE2, PE3) peer with PE1 for l2vpn evpn address family."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - L2 EVPN via PE1 Route Reflector (Priority: P1)

An operator deploys the lab and verifies that PE1 acts as route reflector for l2vpn evpn routes. PE2 and PE3 peer with PE1 (not TOR) for the l2vpn evpn address family. L2 ping between all PE bridge ports still works, and EVPN Type-2/Type-3 routes are reflected by PE1.

**Why this priority**: Core change — moves EVPN route reflection from TOR to PE1. Must work for L2 overlay to function.

**Independent Test**: Deploy lab, check BGP l2vpn evpn summary on PE1 showing PE2 and PE3 as route-reflector clients. Ping between bridge ports. Verify EVPN routes on PE2/PE3 show PE1 as next hop for reflected routes.

**Acceptance Scenarios**:

1. **Given** a deployed topology, **When** the operator checks BGP l2vpn evpn summary on PE1, **Then** PE2 and PE3 are listed as active route-reflector clients.
2. **Given** a deployed topology, **When** the operator checks BGP l2vpn evpn neighbors on PE2, **Then** PE2 peers with PE1 (not TOR) for l2vpn evpn.
3. **Given** a deployed topology, **When** ping is sent from PE2's bridge port to PE3's bridge port, **Then** ping succeeds with 0% packet loss (routes reflected by PE1).
4. **Given** a deployed topology, **When** the operator checks EVPN routes on PE2, **Then** Type-2 routes from PE3 are present, reflected via PE1.

---

### User Story 2 - TOR No Longer Reflects EVPN Routes (Priority: P1)

TOR stops reflecting l2vpn evpn routes. The l2vpn evpn address family is removed from TOR's BGP configuration. TOR continues to reflect ipv4/ipv6 vpn routes for SRv6 as before.

**Why this priority**: Clean separation — TOR handles SRv6 VPN reflection only, PE1 handles EVPN reflection. Avoids duplicate route reflection.

**Independent Test**: Check TOR BGP config — no l2vpn evpn address family. Verify ipv4/ipv6 vpn sessions still active on TOR.

**Acceptance Scenarios**:

1. **Given** a deployed topology, **When** the operator checks BGP summary on TOR, **Then** no l2vpn evpn address family is present.
2. **Given** a deployed topology, **When** the operator checks ipv4/ipv6 vpn sessions on TOR, **Then** all PE neighbors are active for VPN address families.

---

### User Story 3 - Non-Regression: Existing Functionality Preserved (Priority: P1)

All existing functionality continues to work: L2 ping between PE bridge ports, ping from bridge port to RemotePE VRF loopback, SRv6 VRF-to-VRF connectivity.

**Why this priority**: Must not break existing L2 EVPN or SRv6 L3VPN functionality.

**Independent Test**: Run full quickstart validation — L2 pings, RemotePE ping, SRv6 VPN ping.

**Acceptance Scenarios**:

1. **Given** a deployed topology, **When** ping is sent between all PE bridge port pairs, **Then** all pings succeed with 0% packet loss.
2. **Given** a deployed topology, **When** ping is sent from PE1's bridge port to RemotePE's VRF loopback, **Then** ping succeeds.
3. **Given** a deployed topology, **When** ping is sent from PE1's VRF loopback to RemotePE's VRF loopback, **Then** ping succeeds (SRv6 VPN).

---

### Edge Cases

- What happens when PE1 (route reflector) goes down — do PE2/PE3 lose all EVPN routes?
- What happens if PE2/PE3 cannot reach PE1's BGP update-source address — does EVPN peering fail gracefully?
- Does PE1 still participate as a VTEP while also being the route reflector?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: PE1 MUST act as route reflector for the l2vpn evpn address family.
- **FR-002**: PE2 and PE3 MUST peer with PE1 for l2vpn evpn (not with TOR).
- **FR-003**: PE1 MUST mark PE2 and PE3 as route-reflector-client in the l2vpn evpn address family.
- **FR-004**: TOR MUST NOT have the l2vpn evpn address family configured — EVPN reflection is handled entirely by PE1.
- **FR-005**: TOR MUST continue to reflect ipv4 vpn and ipv6 vpn routes for SRv6 L3VPN (unchanged).
- **FR-006**: PE1 MUST continue to function as a VTEP (bridge, VXLAN, bridge port IP) in addition to being the route reflector.
- **FR-007**: L2 ping between all PE bridge port pairs MUST continue to work.
- **FR-008**: Ping from any PE's bridge port to RemotePE's VRF loopback MUST continue to work.
- **FR-009**: SRv6 VRF-to-VRF connectivity (PE↔RemotePE) MUST continue to work.
- **FR-010**: PE2 and PE3 MUST use PE1's loopback address as their l2vpn evpn BGP peer address.

### Key Entities

- **PE1 (Route Reflector + VTEP)**: Dual role — reflects EVPN routes to PE2/PE3 AND participates as a VTEP with its own bridge port.
- **PE2, PE3 (EVPN Clients)**: Peer with PE1 for l2vpn evpn instead of TOR.
- **TOR (SRv6 VPN RR only)**: Continues reflecting ipv4/ipv6 vpn routes. No longer involved in EVPN.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: BGP l2vpn evpn session between PE1↔PE2 and PE1↔PE3 is established and exchanging routes.
- **SC-002**: No l2vpn evpn address family configured on TOR.
- **SC-003**: Ping between all PE bridge port pairs succeeds with 0% packet loss.
- **SC-004**: Ping from any PE's bridge port to RemotePE's VRF loopback succeeds.
- **SC-005**: SRv6 VRF-to-VRF ping (PE↔RemotePE) succeeds.
- **SC-006**: EVPN Type-2 routes from PE3 visible on PE2 (reflected via PE1) and vice versa.

## Assumptions

- PE1's loopback IPv6 address (fc00:0:1::1) is reachable from PE2 and PE3 via ISIS underlay and can serve as BGP update-source for l2vpn evpn peering.
- PE1 can act as both VTEP and route reflector simultaneously — standard FRR behavior.
- The l2vpn evpn peering between PEs uses iBGP (same AS 65500) — route reflection is valid.
- PE2/PE3 continue to peer with TOR for ipv4/ipv6 vpn (SRv6). Only l2vpn evpn peering moves to PE1.
- Since this changes peering topology, the FRR template may need conditional logic or separate handling for PE1 vs PE2/PE3 l2vpn evpn configuration.
- Seed pings in setup.sh continue to handle silent host problem after the peering change.
