# Data Model: PE1 as EVPN Route Reflector

## BGP Peering Topology Change

### Before (TOR as EVPN RR)

```
PE1 ──l2vpn evpn──→ TOR (RR) ←──l2vpn evpn── PE2
                       ↑
PE3 ──l2vpn evpn───────┘
```

### After (PE1 as EVPN RR)

```
PE2 ──l2vpn evpn──→ PE1 (RR + VTEP) ←──l2vpn evpn── PE3

TOR: ipv4/ipv6 vpn only (no l2vpn evpn)
```

## Per-Node BGP Configuration

| Node     | l2vpn evpn peers           | Role             | ipv4/ipv6 vpn peer |
|----------|----------------------------|------------------|---------------------|
| PE1      | PE2 (fc00:0:2::1), PE3 (fc00:0:3::1) | RR server + VTEP | TOR (fc00:0:10::1) |
| PE2      | PE1 (fc00:0:1::1)          | RR client + VTEP | TOR (fc00:0:10::1) |
| PE3      | PE1 (fc00:0:1::1)          | RR client + VTEP | TOR (fc00:0:10::1) |
| RemotePE | None                       | No EVPN          | TOR (fc00:0:10::1) |
| TOR      | None                       | No EVPN          | All PEs (RR server) |

## Route Reflection Flow

1. PE2 originates Type-2 (MAC/IP) for 192.168.10.2 → sends to PE1
2. PE1 reflects to PE3 (sets ORIGINATOR_ID, adds CLUSTER_LIST)
3. PE3 installs remote MAC/IP in bridge FDB via zebra
4. PE1 also installs PE2's MAC/IP locally (PE1 is both RR and VTEP)
