#!/bin/sh

echo "----Add new IP to lab2-br1 from the same network of the namespaces----\n"

ip route add 10.10.10.0/24 dev lab2-br1
sleep 2
# after this the packets reach the namespaces but the replies does not reach the host machine
echo "----Ping all the namespaces----\n"

ping -c 1 -w 1 10.10.10.1
ping -c 1 -w 1 10.10.10.2
ping -c 1 -w 1 10.10.10.3
ping -c 1 -w 1 10.10.10.4

echo "----print the arp resolution----\n"

arp -n

echo "----Checkout the namespace IPs(incomplete)----\n"
echo "----Add new route from host to namespaces----\n"

ip netns exec yellow ip route add 10.0.2.0/24 dev veth-yellow
ip netns exec green ip route add 10.0.2.0/24 dev veth-green
ip netns exec violet ip route add 10.0.2.0/24 dev veth-violet
ip netns exec cyan ip route add 10.0.2.0/24 dev veth-cyan

echo "----check the arp----\n"

arp -n

echo "----check the route----\n"

route -n

echo "----Ping all the namespaces again----\n"

ping -c 1 -w 1 10.10.10.1
ping -c 1 -w 1 10.10.10.2
ping -c 1 -w 1 10.10.10.3
ping -c 1 -w 1 10.10.10.4

echo "----Pinging internet from the namespace----\n"

ip netns exec yellow ping -c 1 -w 1 8.8.8.8
ip netns exec green ping -c 1 -w 1 8.8.8.8
ip netns exec violet ping -c 1 -w 1 8.8.8.8
ip netns exec cyan ping -c 1 -w 1 8.8.8.8

echo "----Add default route for packets going outside the namespace----\n"

GW=$(ip route show default dev lab2-br1 | awk '/default/ {print $3}')
ip netns exec yellow ip route add default via $GW
ip netns exec green ip route add default via $GW
ip netns exec violet ip route add default via $GW
ip netns exec cyan ip route add default via $GW

echo "----Pinging again internet from the namespace----\n"

ip netns exec yellow ping -c 1 -w 1 8.8.8.8
ip netns exec green ping -c 1 -w 1 8.8.8.8
ip netns exec violet ping -c 1 -w 1 8.8.8.8
ip netns exec cyan ping -c 1 -w 1 8.8.8.8

