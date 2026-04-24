#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

sudo clab destroy --topo "${SCRIPT_DIR}/topology.clab.yaml" 2>/dev/null || true
sudo ip link del evpnsrv6-br 2>/dev/null || true

sudo ip link add evpnsrv6-br type bridge
sudo ip link set evpnsrv6-br up

sudo clab deploy --topo "${SCRIPT_DIR}/topology.clab.yaml"

for node in pe1 pe2 pe3 tor remotepe; do
    echo "Setting up ${node}..."
    docker exec clab-evpnsrv6-${node} /setup.sh
done

echo "Topology deployed. Waiting for ISIS and BGP EVPN convergence..."
sleep 15

echo "Seeding L2 EVPN neighbor tables..."
for pe in pe1 pe2 pe3; do
    for target in 192.168.10.1 192.168.10.2 192.168.10.3; do
        docker exec clab-evpnsrv6-${pe} ping -c 1 -W 1 -I br10 ${target} &>/dev/null &
    done
done
wait
sleep 2
echo "Ready."
