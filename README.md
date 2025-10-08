# SRv6 L3VPN Lab

This is a Containerlab-based SRv6 (Segment Routing over IPv6) L3VPN demonstration using FRRouting.

## Network Topology

```
┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐         ┌─────────┐
│ HOST1   │─────────│   pe   │─────────│   al    │─────────│   sp    │─────────│   bl    │─────────│ HOST2   │
│         │  eth1   │   (PE)  │  eth2   │   (P)   │  eth2   │   (P)   │  eth2   │  (PE)   │  eth2   │         │
│ Client  │         │         │         │         │         │         │         │         │         │ Client  │
└─────────┘         └─────────┘         └─────────┘         └─────────┘         └─────────┘         └─────────┘
10.1.1.1/24         10.1.1.2/24                                                 10.2.2.2/24         10.2.2.1/24
fc00:0:0:10::1      fc00:0:0:10::2                                              fc00:0:0:20::2      fc00:0:0:20::1
                    VRF: red                                                    VRF: red
                    Lo: fd00:30:12::1                                           Lo: fd00:30:13::1
                    SRv6: fd00:30:12::/48                                       SRv6: fd00:30:13::/48
```

## Architecture Overview

### Router Roles

- **pe, bl**: Provider Edge (PE) routers
  - Run IS-IS for underlay routing
  - Run iBGP for VPN overlay (VPNv4/VPNv6)
  - Configure VRF "red" for customer traffic
  - SRv6 locators with uSID behavior

- **al, sp**: Provider (P) core routers
  - Run IS-IS for transit
  - No BGP, no VRFs
  - Pure IPv6 forwarding

- **HOST1, HOST2**: Customer endpoints
  - Connected to PE routers via VRF "red"

## Deployment

### Prerequisites

- [Containerlab](https://containerlab.dev/)
- Docker

Just run [setup.sh](./setup.sh)

### Node Initialization

Each node has its own `setup.sh` script that is automatically executed when the container starts:

- **HOST1, HOST2**: Configure IP addresses and default routes
- **pe, bl, al, sp**: Enable IPv6/SRv6 forwarding, create VRF interfaces, and configure loopback addresses

These setup scripts are bind-mounted from the host into each container at `/setup.sh` as defined in `poc.clab.yaml`.

## Testing Connectivity

### 1. Ping HOST2 from HOST1

Test end-to-end L3VPN connectivity between customer sites:

```bash
docker exec -it clab-poc-HOST1 ping fc00:0:0:20::1
```

### 2. Ping BL's Loopback from PE (in VRF red)

Test VRF-to-VRF connectivity via SRv6 L3VPN:

```bash
docker exec -it clab-poc-pe ip vrf exec red ping fc00:0:0:40::2 -I fc00:0:0:10::2
```

This pings bl's loopback interface `lored` (fc00:0:0:40::2) which is in VRF red, using pe's VRF red interface as the source.

