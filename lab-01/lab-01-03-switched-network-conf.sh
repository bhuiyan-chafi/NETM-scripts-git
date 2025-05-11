#!/bin/sh
echo "Deleting previous configuration..."
ip -all netns delete
ip link del v-net-0
# so that every packets are forwarded without checking rules
# iptables -P FORWARD ACCEPT
# so that the packets doesn't go through security checks
sysctl -w net.bridge.bridge-nf-call-iptables=0
sleep 5

echo "Creating namespaces..."
ip netns add yellow
ip netns add green
ip netns add violet
ip netns add cyan
sleep 1

echo "Create Linux bridge..."
ip link add v-net-0 type bridge
ip link set dev v-net-0 up

echo "Creating links..."
ip link add veth-yellow type veth peer name veth-yellow-br
ip link add veth-green type veth peer name veth-green-br
ip link add veth-violet type veth peer name veth-violet-br
ip link add veth-cyan type veth peer name veth-cyan-br
sleep 1

echo "Moving interfaces into the namespaces"
ip link set veth-yellow netns yellow
ip link set veth-green netns green
ip link set veth-violet netns violet
ip link set veth-cyan netns cyan
sleep 1

echo "Attaching interfaces to bridge"
ip link set veth-yellow-br master v-net-0
ip link set veth-green-br master v-net-0
ip link set veth-violet-br master v-net-0
ip link set veth-cyan-br master v-net-0
sleep 1

echo "Configuring IP addresses..."
ip -n yellow addr add 10.10.10.1/24 dev veth-yellow
ip -n green addr add 10.10.10.2/24 dev veth-green
ip -n violet addr add 10.10.10.3/24 dev veth-violet
ip -n cyan addr add 10.10.10.4/24 dev veth-cyan
sleep 1

echo "Turning up the interfaces within namespaces..."
ip -n yellow link set veth-yellow up
ip -n green link set veth-green up
ip -n violet link set veth-violet up
ip -n cyan link set veth-cyan up
sleep 1

echo "Turning up the interfaces within default namespace..."
sudo ip link set veth-yellow-br up
sudo ip link set veth-green-br up
sudo ip link set veth-violet-br up
sudo ip link set veth-cyan-br up


