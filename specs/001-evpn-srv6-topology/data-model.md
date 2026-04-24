# Data Model: EVPN SRv6 Containerlab Topology

**Date**: 2026-04-23  
**Spec**: [spec.md](spec.md)

## Entities

### Node

Network device in the containerlab topology.

| Attribute | PE1 | PE2 | PE3 | TOR | RemotePE |
|-----------|-----|-----|-----|-----|----------|
| Role | Provider Edge | Provider Edge | Provider Edge | Transit | Provider Edge |
| Router ID | 10.0.0.1 | 10.0.0.2 | 10.0.0.3 | 10.0.0.10 | 10.0.0.20 |
| Loopback IPv4 | 10.0.0.1/32 | 10.0.0.2/32 | 10.0.0.3/32 | 10.0.0.10/32 | 10.0.0.20/32 |
| Loopback IPv6 | fc00:0:1::1/128 | fc00:0:2::1/128 | fc00:0:3::1/128 | fc00:0:10::1/128 | fc00:0:20::1/128 |
| ISIS NET | 49.0001.0000.0000.0001.00 | 49.0001.0000.0000.0002.00 | 49.0001.0000.0000.0003.00 | 49.0001.0000.0000.0010.00 | 49.0001.0000.0000.0020.00 |
| Has VRF | Yes | Yes | Yes | No | Yes |
| Has SRv6 | Yes | Yes | Yes | No | Yes |
| Has BGP | Yes | Yes | Yes | No | Yes |

### Link

Connection between nodes.

| Link | Interface A | Interface B | IPv4 A | IPv4 B | IPv6 A | IPv6 B |
|------|------------|------------|--------|--------|--------|--------|
| PE1↔Bridge | pe1:eth1 | bridge:pe1 | 10.100.0.1/24 | — | fc00:100::1/64 | — |
| PE2↔Bridge | pe2:eth1 | bridge:pe2 | 10.100.0.2/24 | — | fc00:100::2/64 | — |
| PE3↔Bridge | pe3:eth1 | bridge:pe3 | 10.100.0.3/24 | — | fc00:100::3/64 | — |
| TOR↔Bridge | tor:eth1 | bridge:tor | 10.100.0.10/24 | — | fc00:100::10/64 | — |
| TOR↔RemotePE | tor:eth2 | remotepe:eth1 | 10.200.0.0/31 | 10.200.0.1/31 | fc00:200::/127 | fc00:200::1/127 |

### SRv6 Locator

Per-node SRv6 segment routing domain.

| Node | Locator Name | Prefix | Block-len | Node-len | Behavior | Source Address |
|------|-------------|--------|-----------|----------|----------|---------------|
| PE1 | MAIN | fd00:1::/48 | 32 | 16 | usid | fd00:1::1 |
| PE2 | MAIN | fd00:2::/48 | 32 | 16 | usid | fd00:2::1 |
| PE3 | MAIN | fd00:3::/48 | 32 | 16 | usid | fd00:3::1 |
| RemotePE | MAIN | fd00:20::/48 | 32 | 16 | usid | fd00:20::1 |

### VRF

Virtual routing and forwarding instance.

| Node | VRF Name | Table ID | RD | RT | Loopback IPv4 | Loopback IPv6 | Loopback Interface |
|------|----------|----------|----|----|---------------|---------------|--------------------|
| PE1 | red | 1100 | 10.0.0.1:2 | 65500:2 | 10.10.1.1/32 | fc00:10:1::1/128 | lored |
| PE2 | red | 1100 | 10.0.0.2:2 | 65500:2 | 10.10.2.1/32 | fc00:10:2::1/128 | lored |
| PE3 | red | 1100 | 10.0.0.3:2 | 65500:2 | 10.10.3.1/32 | fc00:10:3::1/128 | lored |
| RemotePE | red | 1100 | 10.0.0.20:2 | 65500:2 | 10.10.20.1/32 | fc00:10:20::1/128 | lored |

### BGP Peering (iBGP Full Mesh, AS 65500)

| Peer A | Peer B | A Update Source | B Update Source |
|--------|--------|-----------------|-----------------|
| PE1 | PE2 | fc00:0:1::1 | fc00:0:2::1 |
| PE1 | PE3 | fc00:0:1::1 | fc00:0:3::1 |
| PE1 | RemotePE | fc00:0:1::1 | fc00:0:20::1 |
| PE2 | PE3 | fc00:0:2::1 | fc00:0:3::1 |
| PE2 | RemotePE | fc00:0:2::1 | fc00:0:20::1 |
| PE3 | RemotePE | fc00:0:3::1 | fc00:0:20::1 |

Address-family: ipv6 vpn. SRv6 locator: MAIN.

### ISIS Configuration

| Property | Value |
|----------|-------|
| Area | 49.0001 |
| Level | level-1 |
| Topology | ipv6-unicast |
| Segment Routing | on (all nodes) |
| Bridge interfaces | broadcast mode (default) |
| TOR↔RemotePE | point-to-point mode |
