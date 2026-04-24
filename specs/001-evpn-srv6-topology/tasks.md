# Tasks: EVPN SRv6 Containerlab Topology

**Input**: Design documents from `specs/001-evpn-srv6-topology/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested. No test tasks included.

**Organization**: Template-based approach. PE1/PE2/PE3/RemotePE share templates; TOR is hand-written. US2/US3/US4 are satisfied by US1 implementation — no separate phases needed.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Project Structure)

**Purpose**: Create directory structure

- [x] T001 Create directories: pe1/ pe2/ pe3/ tor/ remotepe/ templates/

---

## Phase 2: Foundational (Topology + Shared Configs)

**Purpose**: Containerlab topology and shared FRR config files

**⚠️ CRITICAL**: No node configuration can begin until topology YAML is complete

- [x] T002 Create containerlab topology file in topology.clab.yaml — define all nodes (pe1, pe2, pe3, tor, remotepe as kind:linux with image quay.io/frrouting/frr:10.6.0), bridge node (kind:bridge), all links (pe1:eth1↔bridge:pe1, pe2:eth1↔bridge:pe2, pe3:eth1↔bridge:pe3, tor:eth1↔bridge:tor, tor:eth2↔remotepe:eth1), and bind mounts (<node>/:/etc/frr/ + <node>/setup.sh:/setup.sh)
- [x] T003 [P] Create shared FRR daemons file in templates/daemons — enable zebra, bgpd, isisd, staticd, bfdd; disable unused daemons
- [x] T004 [P] Create shared vtysh.conf in templates/vtysh.conf with `service integrated-vtysh-config`

**Checkpoint**: Foundation ready — templates and node configs can begin

---

## Phase 3: User Story 1 — Deploy Lab Topology (Priority: P1) 🎯 MVP

**Goal**: All 5 nodes deploy with correct IP addressing, ISIS adjacencies, BGP sessions, SRv6 VPN routes, and VRF connectivity

**Independent Test**: Run `./generate.sh && ./setup.sh`, verify all containers running, check ISIS/BGP/SRv6/VRF per quickstart.md

### Templates (PE-type nodes)

- [x] T005 [US1] Create PE FRR config template in templates/pe-frr.conf.tpl — ISIS instance on ${ISIS_IFACE} (with optional ${ISIS_NETWORK_TYPE} via conditional line) and lo; level-1, area 49.0001, ipv6-unicast, segment-routing on. BGP AS 65500 with router-id ${ROUTER_ID}, iBGP peers ${PEER1_ADDR}, ${PEER2_ADDR}, ${PEER3_ADDR} using update-source ${BGP_UPDATE_SOURCE}, address-family ipv6 vpn with SRv6 locator MAIN. BGP VRF red: sid vpn per-vrf export auto, redistribute connected, RD ${ROUTER_ID}:2, RT 65500:2 for ipv4+ipv6 unicast. SRv6 locator MAIN prefix ${SRV6_PREFIX} block-len 32 node-len 16 behavior usid, source-address ${SRV6_SOURCE}
- [x] T006 [US1] Create PE setup script template in templates/pe-setup.sh.tpl — enable forwarding + SRv6 sysctls + vrf strict_mode, create dummy sr0, add loopback addresses (${LOOPBACK_V4}, ${LOOPBACK_V6}, ${SRV6_LOOPBACK} on lo), add link addresses (${LINK_V4}, ${LINK_V6} on ${ISIS_IFACE}), create VRF red (table 1100), create dummy lored in VRF red with ${VRF_LO_V4} and ${VRF_LO_V6}, bring up interfaces

### Generator Script

- [x] T007 [US1] Create generate.sh — define per-node variable sets for PE1 (router-id 10.0.0.1, loopback fc00:0:1::1, SRv6 fd00:1::/48, bridge 10.100.0.1/24, VRF lo 10.10.1.1/32, ISIS broadcast, peers PE2/PE3/RemotePE), PE2 (10.0.0.2, fc00:0:2::1, fd00:2::/48, 10.100.0.2/24, 10.10.2.1/32, broadcast, peers PE1/PE3/RemotePE), PE3 (10.0.0.3, fc00:0:3::1, fd00:3::/48, 10.100.0.3/24, 10.10.3.1/32, broadcast, peers PE1/PE2/RemotePE), RemotePE (10.0.0.20, fc00:0:20::1, fd00:20::/48, 10.200.0.1/31+fc00:200::1/127, 10.10.20.1/32, point-to-point, peers PE1/PE2/PE3). For each node: export variables, envsubst templates to <node>/frr.conf and <node>/setup.sh, copy templates/daemons and templates/vtysh.conf to <node>/. All per data-model.md

### TOR Node (hand-written, ISIS-only)

- [x] T008 [P] [US1] Create TOR FRR config in tor/frr.conf — ISIS instance CORE on eth1 (broadcast, bridge segment) and eth2 (point-to-point, to remotepe) and lo; level-1, area 49.0001, ipv6-unicast topology, segment-routing on. NET 49.0001.0000.0000.0010.00
- [x] T009 [P] [US1] Create TOR setup script in tor/setup.sh — enable forwarding sysctls (ipv4/ipv6 forwarding, seg6_flowlabel, seg6_enabled), add loopback addresses (10.0.0.10/32, fc00:0:10::1/128 on lo), add bridge link addresses (10.100.0.10/24, fc00:100::10/64 on eth1), add p2p link addresses (10.200.0.0/31, fc00:200::/127 on eth2)

### Global Orchestration

- [x] T010 [US1] Create global setup script in setup.sh — destroy existing lab (sudo clab destroy --topo topology.clab.yaml, ignore errors), deploy fresh lab (sudo clab deploy --topo topology.clab.yaml), then docker exec clab-evpnsrv6-{pe1,pe2,pe3,tor,remotepe} /setup.sh for each node

**Checkpoint**: Run `./generate.sh && ./setup.sh` — all nodes up, ISIS adjacencies formed, BGP sessions established, SRv6 VPN routes exchanged, VRF pings PE↔RemotePE working. Validates US1 (deploy), US2 (SRv6 connectivity), US3 (teardown/redeploy), US4 (VRF loopbacks).

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Permissions and validation

- [x] T011 [P] Make all scripts executable: chmod +x setup.sh generate.sh tor/setup.sh templates/pe-setup.sh.tpl
- [x] T012 Run generate.sh to produce pe1/ pe2/ pe3/ remotepe/ configs, then run quickstart.md validation — deploy topology, verify ISIS adjacencies, BGP sessions, SRv6 VPN routes, VRF-to-VRF pings (PE1/PE2/PE3 → RemotePE)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS templates and node configs
- **US1 (Phase 3)**: Depends on Foundational
- **Polish (Phase 4)**: Depends on US1

### Within Phase 3 (US1)

```
T005 (pe-frr.conf.tpl) ─┐
T006 (pe-setup.sh.tpl) ──┼── T007 (generate.sh) ── T010 (global setup.sh)
T008 (tor frr.conf) ─────┘
T009 (tor setup.sh) ──────────────────────────────── T010
```

- T005 + T006: sequential (same template pattern, frr.conf informs setup.sh)
- T008 ‖ T009: parallel with T005+T006 (different directory)
- T007: after T005+T006 (needs templates to exist)
- T010: after T007+T008+T009 (needs all node configs)

### Parallel Opportunities

- T003 (daemons) ‖ T004 (vtysh.conf) — different files
- T005+T006 (templates) ‖ T008+T009 (TOR) — different directories
- T011 can run anytime after Phase 3

### User Story Dependencies

- **US1 (P1)**: Deploy topology — core implementation
- **US2 (P1)**: SRv6 connectivity — satisfied by US1 (BGP+SRv6 in templates)
- **US3 (P2)**: Teardown/redeploy — satisfied by US1 (global setup.sh handles destroy+deploy)
- **US4 (P2)**: VRF loopbacks — satisfied by US1 (pe-setup.sh.tpl creates lored with unique addresses)

---

## Implementation Strategy

### MVP First (US1 = Full Lab)

1. Phase 1: Create directories
2. Phase 2: topology.clab.yaml + shared configs
3. Phase 3: Templates → generate.sh → TOR configs → global setup.sh
4. **STOP and VALIDATE**: `./generate.sh && ./setup.sh`, verify per quickstart.md
5. Single phase delivers all four user stories

### Build Order

1. Templates first (pe-frr.conf.tpl, pe-setup.sh.tpl) — core reusable configs
2. TOR in parallel (hand-written, simple)
3. generate.sh — produces pe1/ pe2/ pe3/ remotepe/ from templates
4. Global setup.sh — orchestration
5. Generate, deploy, validate

---

## Notes

- Templates use `${VARIABLE}` syntax for envsubst
- generate.sh defines all per-node variables inline and loops over PE-type nodes
- TOR is hand-written — unique ISIS-only config doesn't benefit from templating
- All addressing from data-model.md
- FRR image: quay.io/frrouting/frr:10.6.0
- Topology name: evpnsrv6 (containers named clab-evpnsrv6-{node})
- Generated files (pe1/ pe2/ pe3/ remotepe/) could be .gitignored if desired
