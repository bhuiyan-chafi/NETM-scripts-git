#!/bin/sh
echo "Disable routing in RED namespace..."
sudo ip netns exec red sysctl net.ipv4.ip_forward=0
