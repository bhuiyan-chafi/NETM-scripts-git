#!/bin/sh
echo
echo "--- PING from YELLOW to GOOGLE..."
ip netns exec yellow ping -c 3 8.8.8.8
sleep 2

echo
echo "--- PING from CYAN to GOOGLE..."
ip netns exec cyan ping -c 3 8.8.8.8
sleep 2

echo
echo "--- PING from HOST to GOOGLE..."
ping -c 3 8.8.8.8
sleep 2


