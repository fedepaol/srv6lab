#!/bin/bash
#

sudo clab deploy --reconfigure --topo direct.clab.yml

docker exec clab-evpnl3-pe1 /setup.sh
docker exec clab-evpnl3-pe2 /setup.sh
docker exec clab-evpnl3-router /setup.sh
