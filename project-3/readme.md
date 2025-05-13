# Credits

This lab and script credit goes to our dear profesor: Alessio Giorgetti. Link to the: [github](https://github.com/alessiocnit/NETM-scripts-git)

# Hosts

    10.10.100.1 h1
    10.10.200.2 h2
    10.10.100.3 h3
    10.10.200.4 h4

# How to the run the Network without the mininet

    cd project-3
    chmod +x topology.sh
    sudo ./topology.sh

# Playing with the network

There should be Two Vlans. Let's confirm:

    sudo ovs-vsctl show

If you are looking for precise information about VLANs:

    sudo ovs-vsctl --format=table --columns=name,tag,trunks list Port

Hosts of the same VLAN can ping each other only:

    sudo ip netns exec h1 ping 10.10.100.3 -- Should work --
    sudo ip netns exec h1 ping 10.10.200.4 -- Should work --

    sudo ip netns exec h1 ping 10.10.200.4 -- x Should work --

# Running the topology in mininet

Clear the current configuration:

    sudo ./clear-bash-topo.sh

If you running it for the first time aftert starting the VM:

    sudo ./controller-create-start.sh

Login into ONOS controller through CLI:

    onos 172.17.0.2 -l karaf

Go to web-browser and login:

    http://172.17.0.2:8181/onos/ui/#/topo2

Run the mininet topology:

    sudo python3 mininet-topo.py or sudo python3 mininet-topo.py 5 #change 5 with number of switches

Check the Topology in ONOS GUI

## The topology must work like the topology created with bash.sh

Incase if you are not able to ping h3 from h1 or h4 from h2, exit from mininet and perform these:

    sudo mn -c

    sudo ./controller-restart.sh

Open onos controller in another terminal:

    onos 172.17.0.2 -l karaf

Run the mininet script:

    sudo python3 mininet-topo.py

Everything should work fine now.

# Traceroute and iperf measurements

    h1 traceroute h3

In our topology all of the “hops” between h1 and h3 are pure Layer-2 switches — there are no routers to decrement the IP TTL or generate ICMP “Time Exceeded” messages. Traceroute works by sending packets with TTL=1,2,3,… and listening for the ICMP “TTL exceeded” replies from each router along the path. Because OVS in “standalone” (or “normal”) mode simply bridges at L2 and does not decrement the IPv4 TTL on transit, no intermediate device ever sends back a TTL-expired message, so your traceroute probes just time out (showing “\* \* \*”).

## iperf measurements

Run the xterm from h1 and h3 (inside mininet):

    xterm h1 h3

Run the server from h1:

    iperf -s

Run the client from h3:

    iperf -c 10.10.100.1 #ip of h1

Now you can test with different aspects such as: udp client, rating bandwidth, several sessions(disscussed in the presentation).s
