#!/bin/sh
echo "--- Remove port 300 from br1-trunk and br2-trunk ---"

ovs-vsctl remove port br1-trunk trunks 300
ovs-vsctl remove port br2-trunk trunks 300

echo "--- Add port 100 in br1-trunk and br2-trunk ---"
#set command reset the whole array, it will now append so you have to add all IDs. In that sense yes, there is no point removing port 300.
ovs-vsctl set port br1-trunk trunks=100,200
ovs-vsctl set port br2-trunk trunks=100,200