# Research: EVPN SRv6 Containerlab Topology

**Date**: 2026-04-23  
**Spec**: [spec.md](spec.md)

## R1: ISIS on Shared L2 Bridge Segment

**Decision**: Use ISIS broadcast mode (default) on bridge-facing interfaces. Use point-to-point mode on TOR↔RemotePE link.

**Rationale**: Linux bridge forwards L2 multicast (AllL1ISs: 01:80:C2:00:00:14) correctly. Broadcast mode handles multi-access topology with automatic DIS election. Point-to-point is only appropriate for dedicated links.

**Alternatives considered**:
- Point-to-point ISIS on bridge: incorrect for multi-access, would result in N*(N-1)/2 separate adjacencies instead of proper DIS behavior
- OSPF instead of ISIS: user explicitly requested ISIS; ISIS also provides native IPv6 topology support

## R2: BGP Peering Model

**Decision**: iBGP full mesh (AS 65500) among PE1, PE2, PE3, RemotePE. TOR is pure transit (no BGP).

**Rationale**: With 4 BGP speakers, full mesh = 6 sessions, which is manageable. Route reflector adds unnecessary complexity for a lab. Reference uses iBGP full mesh between 2 endpoints. Peering over loopback addresses (resolved via ISIS).

**Alternatives considered**:
- Route reflector on TOR: adds complexity, TOR would need BGP config
- eBGP: not appropriate for SRv6 L3VPN lab where all nodes are in same AS

## R3: SRv6 Locator Scheme

**Decision**: Each PE and RemotePE gets unique /48 locator with uSID behavior:
- PE1: fd00:1::/48
- PE2: fd00:2::/48
- PE3: fd00:3::/48
- RemotePE: fd00:20::/48

Block-len 32, node-len 16 (matching reference pattern).

**Rationale**: fd00::/8 is IPv6 unique-local range, safe for lab use. Numbering follows node identity. /48 with 32+16 split matches reference and FRR SRv6 uSID implementation.

**Alternatives considered**:
- fd00:30:XX scheme (reference pattern): works but fd00:X:: is simpler for 4 nodes
- Larger locators (/32, /64): /48 is standard for SRv6 uSID

## R4: IP Addressing Plan

**Decision**: Systematic addressing with clear structure:

| Segment | IPv4 | IPv6 |
|---------|------|------|
| Underlay loopbacks | 10.0.0.X/32 | fc00:0:X::1/128 |
| Bridge segment | 10.100.0.X/24 | fc00:100::X/64 |
| TOR-RemotePE link | 10.200.0.{0,1}/31 | fc00:200::{0,1}/127 |
| VRF loopbacks | 10.10.X.1/32 | fc00:10:X::1/128 |
| SRv6 locators | N/A | fd00:X::/48 |

**Rationale**: Clean, predictable addressing. Each node's identity embedded in address. fc00::/7 for underlay links, fd00::/8 for SRv6 locators.

## R5: VRF Configuration

**Decision**: Single VRF "red" on each PE and RemotePE. Table ID 1100 (matching reference). Loopback via dummy interface in VRF.

**Rationale**: Reference pattern proven to work. Single VRF meets spec requirements. Dummy interface in VRF provides stable loopback for ping testing.

**Alternatives considered**:
- Multiple VRFs per PE: not required by spec
- Different table IDs per node: unnecessary, same table ID works in separate network namespaces

## R6: Containerlab Bridge Configuration

**Decision**: Use `kind: bridge` node type in containerlab topology. PE1/PE2/PE3/TOR connect to bridge via standard endpoints.

**Rationale**: Matches openperouter reference pattern. Creates proper L2 broadcast domain. No image needed for bridge node.

**Alternatives considered**:
- Host-level bridge pre-created: requires manual setup, not portable
- VXLAN overlay: overkill for local lab

## R7: FRR Image Version

**Decision**: Use `quay.io/frrouting/frr:10.6.0`.

**Rationale**: User-specified version. FRR 10.6 supports ISIS + BGP + SRv6 uSID. Reference used 10.4.1 but 10.6 is preferred.

**Alternatives considered**:
- FRR 10.4.1 (reference version): works but user prefers 10.6
- Latest FRR: 10.6 is the explicit choice
