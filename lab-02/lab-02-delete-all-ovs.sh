#!/bin/sh
for br in $(ovs-vsctl list-br); do
    echo "Deleting ovs: $br"
    ovs-vsctl del-br $br
done