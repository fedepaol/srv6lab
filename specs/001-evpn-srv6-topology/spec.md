# Feature Specification: EVPN SRv6 Containerlab Topology

**Feature Branch**: `002-evpn-srv6-topology`  
**Created**: 2026-04-23  
**Status**: Draft  
**Input**: User description: "Containerlab topology with PE1/PE2/PE3 connected via linux bridge to TOR, TOR connected to remote PE, with ISIS underlay, SRv6 overlay, VRFs on PEs, and per-VRF loopbacks"

## Clarifications

### Session 2026-04-23

- Q: Should PE-to-PE VRF traffic (PE1↔PE2, PE1↔PE3, PE2↔PE3) be tested and validated, or only PE↔RemotePE? → A: PE↔RemotePE only. PE↔PE connectivity may work as a natural consequence of the BGP full mesh but is not a test requirement.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deploy Lab Topology (Priority: P1)

An operator deploys the full EVPN SRv6 lab topology with a single command. The topology includes five network nodes (PE1, PE2, PE3, TOR, Remote PE) interconnected through a linux bridge. All nodes come up with correct IP addressing and routing adjacencies.

**Why this priority**: Without a working topology, no other testing or validation is possible.

**Independent Test**: Run the global setup script and verify all nodes are reachable, all links have correct IPv4 and IPv6 addresses, and ISIS adjacencies form.

**Acceptance Scenarios**:

1. **Given** no lab is running, **When** the operator runs the global setup script, **Then** all five nodes and the linux bridge are deployed and running.
2. **Given** a deployed topology, **When** the operator checks link addresses on any node, **Then** each link has both an IPv4 and an IPv6 address assigned.
3. **Given** a deployed topology, **When** the operator checks ISIS adjacencies, **Then** all expected ISIS neighbor relationships are established.

---

### User Story 2 - SRv6 VPN Connectivity Between PEs and Remote PE (Priority: P1)

Traffic originating from a VRF on any PE (PE1, PE2, PE3) reaches the corresponding VRF on the Remote PE via SRv6 encapsulation over the ISIS underlay, transiting through the TOR node.

**Why this priority**: SRv6 L3VPN connectivity is the core purpose of the lab — validating EVPN SRv6 data plane behavior.

**Independent Test**: From a VRF loopback on PE1, ping the VRF loopback on Remote PE and verify packets traverse the SRv6 path.

**Acceptance Scenarios**:

1. **Given** a fully deployed topology with ISIS and SRv6 configured, **When** a ping is sent from PE1's VRF loopback to Remote PE's VRF loopback, **Then** the ping succeeds.
2. **Given** a fully deployed topology, **When** a ping is sent from PE2's VRF loopback to Remote PE's VRF loopback, **Then** the ping succeeds.
3. **Given** a fully deployed topology, **When** a ping is sent from PE3's VRF loopback to Remote PE's VRF loopback, **Then** the ping succeeds.

---

### User Story 3 - Teardown and Redeploy (Priority: P2)

An operator tears down the running lab and redeploys it cleanly. The global setup script handles both teardown of any existing lab and fresh deployment.

**Why this priority**: Rapid iteration requires clean teardown/redeploy cycles without manual cleanup.

**Independent Test**: Deploy the lab, run the teardown/setup sequence, verify the lab is fully operational again with no stale state.

**Acceptance Scenarios**:

1. **Given** a running lab, **When** the operator runs the global setup script, **Then** the existing lab is torn down and a fresh deployment starts.
2. **Given** a torn-down lab, **When** the operator runs the global setup script, **Then** the lab deploys successfully without errors from stale state.

---

### User Story 4 - Per-VRF Loopback Addressing (Priority: P2)

Each PE node has a VRF with a loopback interface carrying a unique IPv4 and IPv6 address. These loopback addresses are distinct across all PEs, enabling per-PE identification and reachability testing within the VRF.

**Why this priority**: Unique per-VRF loopbacks are essential for validating end-to-end VPN reachability and distinguishing traffic sources.

**Independent Test**: Inspect each PE's VRF loopback and verify addresses are unique; ping between VRF loopbacks across different PEs.

**Acceptance Scenarios**:

1. **Given** a deployed topology, **When** the operator inspects VRF loopbacks on PE1, PE2, and PE3, **Then** each has a distinct IPv4 and IPv6 address.
2. **Given** a deployed topology, **When** the operator inspects the Remote PE's VRF, **Then** it also has a loopback with a unique IPv4 and IPv6 address.

---

### Edge Cases

- What happens when the global setup script is run while a partial deployment exists (some nodes up, some down)?
- How does the topology behave when one PE node fails — do the remaining PEs maintain SRv6 connectivity to Remote PE?
- What happens if the linux bridge is not available or fails to initialize?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Topology MUST include five network nodes: PE1, PE2, PE3, TOR, and Remote PE.
- **FR-002**: PE1, PE2, and PE3 MUST be connected to a shared linux bridge.
- **FR-003**: TOR MUST be connected to the same linux bridge as the three PEs.
- **FR-004**: TOR MUST be connected to Remote PE via a dedicated point-to-point link.
- **FR-005**: Every inter-node link MUST have both an IPv4 and an IPv6 address assigned.
- **FR-006**: All nodes MUST run ISIS as the underlay routing protocol, establishing adjacencies with their neighbors.
- **FR-007**: SRv6 MUST be configured on PE1, PE2, PE3, and Remote PE with unique SRv6 locators per node.
- **FR-008**: Each PE (PE1, PE2, PE3) MUST have a VRF configured and mapped to the SRv6 network for L3VPN service.
- **FR-009**: Remote PE MUST also have a VRF configured and mapped to the SRv6 network.
- **FR-010**: Each VRF on each PE MUST contain a loopback interface with a unique IPv4 address.
- **FR-011**: Each VRF on each PE MUST contain a loopback interface with a unique IPv6 address.
- **FR-012**: A global setup script MUST handle both teardown of any existing deployment and fresh deployment.
- **FR-013**: Each node MUST have its own setup script that configures the node after deployment.
- **FR-014**: The project MUST follow a per-node directory structure where each node has its own routing configuration and setup script.
- **FR-015**: VRF-to-VRF traffic between any PE and the Remote PE MUST traverse the SRv6 data plane.
- **FR-016**: Validation scope for VRF connectivity is PE↔RemotePE only. PE↔PE VRF connectivity is not a test requirement.

### Key Entities

- **PE (Provider Edge)**: Nodes PE1, PE2, PE3 — edge routers that host VRFs and perform SRv6 encapsulation/decapsulation. Connected to TOR via linux bridge.
- **TOR (Top of Rack)**: Transit node connecting the PE cluster (via linux bridge) to the Remote PE. Participates in ISIS underlay.
- **Remote PE**: Edge router on the far side, hosting a VRF and SRv6 endpoint. Peer to PE1/PE2/PE3 for L3VPN.
- **Linux Bridge**: Layer-2 broadcast domain connecting PE1, PE2, PE3, and TOR, simulating a shared LAN segment.
- **VRF**: Virtual routing instance on each PE and Remote PE, carrying tenant traffic over the SRv6 overlay.
- **VRF Loopback**: Per-VRF loopback interface with unique IPv4 and IPv6 addresses for reachability testing.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All five nodes and the linux bridge deploy successfully within 2 minutes of running the setup script.
- **SC-002**: 100% of inter-node links have both IPv4 and IPv6 addresses correctly assigned after deployment.
- **SC-003**: ISIS adjacencies form on all expected links within 30 seconds of node setup completion.
- **SC-004**: VRF-to-VRF pings between any PE's loopback and the Remote PE's loopback succeed with 0% packet loss.
- **SC-005**: Teardown and redeploy cycle completes without manual intervention or error.
- **SC-006**: Each PE's VRF loopback has a unique IPv4 and unique IPv6 address — no duplicates across the four nodes.

## Assumptions

- The operator has containerlab installed and operational on the host machine.
- The host machine has sufficient resources (CPU, memory) to run five concurrent network nodes.
- The host OS supports linux bridges and the required network namespaces.
- SRv6 kernel support is available on the host.
- The routing daemon software image used supports ISIS, BGP, and SRv6.
- The TOR node acts as a pure transit/underlay router and does not host a VRF.
- All PEs share a single VRF name, but each has unique addressing within that VRF.
- The linux bridge provides L2 connectivity only — no VLAN tagging or filtering is applied.
- The topology name in containerlab will determine container naming (e.g., `clab-<topology>-<node>`).
