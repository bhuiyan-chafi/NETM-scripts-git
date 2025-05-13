#!/bin/sh
echo "--- Deleting all namespaces..."
ip -all netns delete
sleep 1
echo "--- Disable routing..."
sudo sysctl net.ipv4.ip_forward=0
sleep 1

echo "--- Disable NAT..."
iptables -t nat -D POSTROUTING -s 10.10.10.0/24 -j MASQUERADE
sleep 1

# If you are not sure which network masquerading you did
# sudo iptables -t nat -L POSTROUTING --line-numbers
# then delete the entry
# sudo iptables -t nat -D POSTROUTING -s 10.10.10.0/24 -j MASQUERADE


