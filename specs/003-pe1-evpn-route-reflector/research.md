# Research: PE1 as EVPN Route Reflector

## PE as Both VTEP and Route Reflector

**Decision**: PE1 acts as both VTEP (with bridge/VXLAN) and l2vpn evpn route reflector.
**Rationale**: Standard FRR/BGP behavior — a route reflector can originate its own routes while reflecting others. PE1's locally originated Type-2/Type-3 routes are sent to PE2/PE3, and PE2/PE3's routes are reflected to each other.
**Alternatives considered**: Dedicated RR without VTEP — unnecessary complexity for a 3-node lab.

## Template Refactoring Approach

**Decision**: Replace hardcoded l2vpn evpn AF block with two variables (`${L2EVPN_NEIGHBORS}`, `${L2EVPN_AF_BLOCK}`).
**Rationale**: Each PE needs different l2vpn evpn config — PE1 has two RR clients, PE2/PE3 each have one peer, RemotePE has none. A single `${PEER_ADDR}` can't express this. Multi-line envsubst variables handle the variability cleanly.
**Alternatives considered**: (1) Separate templates per PE role — too much duplication. (2) Hand-written configs — loses template benefit. (3) Conditional logic in template — envsubst doesn't support conditionals.

## RemotePE l2vpn evpn Removal

**Decision**: Remove l2vpn evpn from RemotePE (empty variables).
**Rationale**: RemotePE has no VNIs. Previously had l2vpn evpn peering with TOR (harmless). Since TOR no longer has l2vpn evpn, the session wouldn't establish anyway. Cleaner to remove.
**Alternatives considered**: Keep the dead config — rejected for cleanliness.

## TOR l2vpn evpn Removal

**Decision**: Remove l2vpn evpn AF from TOR entirely.
**Rationale**: EVPN route reflection moves to PE1. TOR continues ipv4/ipv6 vpn reflection for SRv6. No overlap or conflict.
**Alternatives considered**: Keep l2vpn evpn on TOR as backup — unnecessary for a lab.
