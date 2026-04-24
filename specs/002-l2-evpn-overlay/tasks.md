# Tasks: L2 EVPN VXLAN Overlay

**Input**: Design documents from `specs/002-l2-evpn-overlay/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

## Phase 1: Setup

**Purpose**: Create new template files for L2 EVPN

- [x] T001 Create L2 EVPN setup template in templates/l2evpn-setup.sh.tpl

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Modify existing templates and configs that all user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 [P] Add l2vpn evpn address family and VRF network variable to templates/pe-frr.conf.tpl
- [x] T003 [P] [US3] Add l2vpn evpn address family with route-reflector-client to tor/frr.conf
- [x] T004 Update generate.sh with L2 EVPN variables and generate_l2evpn function
- [x] T005 Run generate.sh to regenerate pe1/, pe2/, pe3/, remotepe/ configs

**Checkpoint**: All config files generated with L2 EVPN additions

---

## Phase 3: User Story 1 - L2 Ping Between PE Bridge Ports (Priority: P1) 🎯 MVP

**Goal**: PE1, PE2, PE3 share L2 broadcast domain via EVPN VXLAN. Ping between bridge port IPs succeeds.

**Independent Test**: Deploy lab, ping between PE bridge ports, verify neighbor tables populated via EVPN.

### Implementation for User Story 1

- [x] T006 [US1] Add seed pings for L2 EVPN neighbor table population to setup.sh
- [x] T007 [US1] Verify generated pe1/setup.sh, pe2/setup.sh, pe3/setup.sh contain bridge and VXLAN setup
- [x] T008 [US1] Verify generated pe1/frr.conf, pe2/frr.conf, pe3/frr.conf contain l2vpn evpn AF with advertise-all-vni and advertise-svi-ip
- [x] T009 [US1] Verify remotepe/setup.sh does NOT contain bridge/VXLAN setup
- [x] T010 [US1] Verify remotepe/frr.conf has l2vpn evpn AF but no network 192.168.10.0/24 statement

**Checkpoint**: L2 EVPN config complete. Deploy and test PE-to-PE L2 ping.

---

## Phase 4: User Story 2 - Ping from Bridge Port to RemotePE VRF Loopback (Priority: P2)

**Goal**: Ping from any PE's bridge port to RemotePE's VRF loopback succeeds via SRv6.

**Independent Test**: From PE1, `ip vrf exec red ping -I 192.168.10.1 10.10.20.1` succeeds.

### Implementation for User Story 2

- [x] T011 [US2] Verify pe1/frr.conf, pe2/frr.conf, pe3/frr.conf contain `network 192.168.10.0/24` in VRF red ipv4 unicast AF

**Checkpoint**: Bridge port subnet advertised via SRv6 VPN. RemotePE can route return traffic.

---

## Phase 5: User Story 3 - EVPN Route Reflector for L2VPN (Priority: P1)

**Goal**: TOR reflects l2vpn evpn routes between all PEs.

**Independent Test**: `show bgp l2vpn evpn summary` on TOR shows PE1/PE2/PE3 as active neighbors.

### Implementation for User Story 3

- [x] T012 [US3] Verify tor/frr.conf contains l2vpn evpn AF with CLIENTS peer-group activated and route-reflector-client

**Checkpoint**: TOR route reflector distributes L2VPN EVPN routes.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and non-regression

- [x] T013 Verify existing SRv6 VRF config unchanged in generated pe1/frr.conf (non-regression)
- [x] T014 Run quickstart.md validation commands after deployment

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup. T002+T003 parallel. T004 depends on T001+T002. T005 depends on T004.
- **US1 (Phase 3)**: Depends on Phase 2. T007-T010 are verification of generated output.
- **US2 (Phase 4)**: Depends on Phase 2. Verification only.
- **US3 (Phase 5)**: T003 done in Phase 2. T012 is verification only.
- **Polish (Phase 6)**: Depends on all phases.

### User Story Dependencies

- **US3 (TOR RR)**: Must be complete before US1 can function (routes need reflecting)
- **US1 (L2 Ping)**: Independent of US2
- **US2 (RemotePE Ping)**: Requires US1 (bridge must exist) + SRv6 VPN (already working)

### Parallel Opportunities

- T002 + T003: Different files (pe-frr.conf.tpl vs tor/frr.conf)
- T007-T010: All verification tasks, parallel

---

## Implementation Strategy

### MVP First (US1 + US3)

1. Phase 1: Create L2 EVPN template
2. Phase 2: Modify FRR template + TOR config + generate.sh → regenerate
3. Phase 3: Add seed pings → verify configs → deploy → test L2 ping
4. **STOP and VALIDATE**: Ping PE1↔PE2↔PE3 bridge ports

### Incremental Delivery

1. Setup + Foundational → configs generated
2. US1 + US3 → L2 EVPN works between PEs (MVP)
3. US2 → Bridge port to RemotePE via SRv6
4. Polish → non-regression + full quickstart validation

---

## Notes

- Most "implementation" is template/config changes — actual code is Bash + FRR config
- Verification tasks (T007-T012) validate generated output matches plan
- T014 (quickstart validation) requires live deployment — run last
- No test framework — validation is ping + show commands on live topology
