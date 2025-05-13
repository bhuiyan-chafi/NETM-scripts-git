# Executing the first script
    sudo ./lab-03-01-config-vlan-access.sh
## How to check list of VLAN and ports connected to each of them
    sudo ovs-vsctl --format=table --columns=name,tag,trunks list Port

At this point we separated Yellow & Green in one VLAN(100) and Violet & Cyan in another VLAN(200). Now all the namespaces cannot ping themselves like before because they are now tagged with a VLAN configuration. Only namespaces from the same VLAN can ping each other. 

# Execute the second script
    sudo ./lab-03-02-create-second-ovs.sh

## The tagging and Untagging
Imagine this setup: Yellow, Cyan in one bridge(B1) having two VLANS(200,100). Green, Violet in another bridge(B2) having two VLANS(200,100). 

Now a packet goes from Yellow to the bridge B1. The configuring(VLAN 200) will be done insdie the switch(ovs) and port (veth-yellow-br) which will tag the packet with VID(VLAN ID) 200. And when it will go out of the bridge(leaving B1) a 802.1Q header will be added to the Packet by the br trunk port which is **tagging**. Then in bridge2 it will be untagged by the br2-trunk and forwarded to veth-green as a normal ethernet packet.

Inside one ovs there is no tagged frame but configured frame. But due to this configuring, even inside a same ovs you cannot ping different VLANS directly.

When a packet arrives, the bridge and switch remembers the egress packets and stips off the header to send the packet to the desired host.

### If I use different VLAN in different brdige will it work?

For example in this current setup if we put different VLAN IDs for yellow, cyan, green, violet (100,200,300,400), we won't be able to ping green from yellow for having different VLANs.

# Execute the third script
    sudo ./lab-03-03-config-vlan-trunk.sh

Here in this script we intentionally skipped VLAN ID 100, instead we added a VLAN ID which is not associated with any NS. What happens now?

    sudo ovs-vsctl --format=table --columns=name,tag,trunks list Port

As we have 200 tag only in the trunk our packets from green and yellow will travel via the bridges. Only Yellow and Green can ping each other. 

And if you inspect the br-trunk you will see 802.1Q in packets. But it's only at trunk level.

## Ping Green from Yellow
    sudo ip netns exec yellow ping green

The ping should work if everything is okay. Go to wireshark and look at the packet traffic. What do you see? There is traffic in veth-yellow-br and veth-green-br but there is no traffic in bridge, trunk, etc. The reason for this is: SDN the packets flow internally in ovs kernel datapath, so there is no explicit projection of packet flowing in pcap tools like wireshark. But if you try to look at internal datapath you will see packets flowing from the trunk, bridge, etc.
    
    sudo tcpdump -ni br2-trunk -e

But try to dump the bridge packets:

    sudo tcpdump -ni lab2-br1 -e

You will only see the first packet flowed. The reason behind this is: when we send the first packet for address resolution and flow-path it traverses through the network. When the path-flow is installed it directly forwards the consecutive packets and we don't see them in the upper layer like br2.

### Try to ping Violet from Cyan
We intentionally added port 200,300 in the trunks. So it is very normal that Violet and Cyan cannot ping each other. To fix this we fix the trunk ports:

    sudo ./lab-03-03-fix.sh

Ping from Cyan to Violet and vise-versa should work now.

# But what happens in an actual LAN?
All users in the same network should be able to communicate with each other with proper privileges. But due to VLAN they cannot communicate with different VLANs. If we project a real network. 

Yellow -> Engineering
Cyan -> Science
Green -> Businees
Violet -> Administration

All in the same network and should be able to ping each other. But we have different bridge, moreover different VLANs and we cannot do that. 

## Solution?
A common endpoint which can communicate with everyone and can route the traffic to everyone. To test this setup we execute our next steps.

# Red namespace as the router | Execute 4th Script

First we have to clear the current setup:

    sudo ./lab-03-delete-namespaces.sh
    sudo ./lab-03-delete-ovs.sh

Create the new setup:

    sudo ./lab-03-04-create-red-topology.sh

Here the red topology contains two sub-nets, which is possible(explained in theories). And those two sub-nets contains all the namespaces. 

Red -> 10.10.100.1 & 10.10.200.1 (contains VLAN 100,200 via two sub-netns)

So any namespace containing the same subnet can ping each other because they are containing the same VLAN(Yellow, Green - 200 & Violet, Cyan - 100). And it is obvious that red can ping them all.

## How to solve the issue for inter-VLAN routing
But we want to ping all the namepsaces from each other. So, we need to route the packets. And who will be the common routing point? Of course **RED**, because he can communicate with each other.

     sudo ./lab-03-05-add-gateways.sh

And enable ip forwarding so that packets are forwared via default route:

    sudo ./lab-03-06-enable-routing.sh

Now everyone should be able to ping everyone. But?

# What are the issues that has been introduced now?
    1. We cannot ping the internet from the host
    2. We cannot ping a namespace from the host
    3. We cannot ping the internet from the host

