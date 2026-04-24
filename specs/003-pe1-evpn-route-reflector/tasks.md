# Tasks: PE1 as EVPN Route Reflector

**Input**: Design documents from `specs/003-pe1-evpn-route-reflector/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

## Phase 1: Foundational (Template Refactoring)

**Purpose**: Refactor FRR template to support variable-driven l2vpn evpn configuration

**⚠️ CRITICAL**: All user story work depends on this phase

- [ ] T001 Modify templates/pe-frr.conf.tpl — replace hardcoded l2vpn evpn AF with `${L2EVPN_NEIGHBORS}` and `${L2EVPN_AF_BLOCK}` variables
- [ ] T002 Update generate.sh — add L2EVPN_NEIGHBORS and L2EVPN_AF_BLOCK to envsubst variable list and set per-PE values (PE1 as RR with PE2/PE3 clients, PE2/PE3 as clients of PE1, RemotePE empty)
- [ ] T003 Run generate.sh to regenerate pe1/, pe2/, pe3/, remotepe/ configs

**Checkpoint**: Generated FRR configs have correct per-PE l2vpn evpn peering

---

## Phase 2: User Story 1 - L2 EVPN via PE1 Route Reflector (Priority: P1) 🎯 MVP

**Goal**: PE1 reflects l2vpn evpn routes between PE2 and PE3. L2 ping works.

**Independent Test**: BGP l2vpn evpn summary on PE1 shows PE2/PE3 as clients. Ping between bridge ports succeeds.

### Implementation for User Story 1

- [ ] T004 [US1] Verify pe1/frr.conf declares PE2 and PE3 as l2vpn evpn neighbors with route-reflector-client
- [ ] T005 [P] [US1] Verify pe2/frr.conf declares PE1 as l2vpn evpn neighbor (not TOR)
- [ ] T006 [P] [US1] Verify pe3/frr.conf declares PE1 as l2vpn evpn neighbor (not TOR)
- [ ] T007 [US1] Verify remotepe/frr.conf has no l2vpn evpn neighbors or AF block

**Checkpoint**: PE1 route reflector config verified. Deploy and test L2 ping.

---

## Phase 3: User Story 2 - TOR No Longer Reflects EVPN Routes (Priority: P1)

**Goal**: TOR has no l2vpn evpn AF. Still reflects ipv4/ipv6 vpn for SRv6.

**Independent Test**: `show bgp l2vpn evpn summary` on TOR shows no peers. ipv4/ipv6 vpn sessions active.

### Implementation for User Story 2

- [ ] T008 [US2] Remove l2vpn evpn address-family block from tor/frr.conf

**Checkpoint**: TOR handles SRv6 VPN only.

---

## Phase 4: User Story 3 - Non-Regression (Priority: P1)

**Goal**: All existing L2 EVPN and SRv6 L3VPN functionality works after peering change.

**Independent Test**: Full quickstart validation — L2 pings, RemotePE ping, SRv6 VPN ping.

### Implementation for User Story 3

- [ ] T009 [US3] Verify pe1/frr.conf SRv6 VRF config unchanged (sid vpn, rd/rt, import/export vpn)
- [X] T010 [US3] Deploy lab and run full quickstart.md validation

**Checkpoint**: All connectivity verified after peering topology change.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies. T001→T002→T003 sequential.
- **US1 (Phase 2)**: Depends on Phase 1. T004-T007 verification tasks, T005+T006 parallel.
- **US2 (Phase 3)**: Independent of US1 (different file: tor/frr.conf). Can run in parallel with Phase 1.
- **US3 (Phase 4)**: Depends on Phase 1 + US2. Requires deployment.

### Parallel Opportunities

- T005 + T006: Different files (pe2/frr.conf vs pe3/frr.conf)
- T008 (US2) can run in parallel with T001-T003 (different file: tor/frr.conf)

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Phase 1: Refactor template + regenerate configs
2. Phase 2: Verify PE1 as RR
3. Phase 3: Remove l2vpn evpn from TOR
4. **STOP and VALIDATE**: Deploy, check l2vpn evpn peering, test L2 ping

### Full Delivery

1. MVP + Phase 4: Full non-regression validation

---

## Notes

- Main work is template refactoring (T001-T002) — rest is verification
- T008 (TOR change) is a simple deletion, can be done anytime
- T010 requires live deployment — must be last
