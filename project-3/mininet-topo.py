#!/usr/bin/env python3

"""
Custom linear VLAN topology with two hosts per end, tagged on 100/200,
using an arbitrary number of switches, driven by a Remote ONOS controller.
"""

import sys
from mininet.topo import Topo
from mininet.net  import Mininet
from mininet.node import RemoteController, OVSSwitch, CPULimitedHost
from mininet.link import TCLink
from mininet.cli  import CLI
from mininet.log  import setLogLevel, info


class ProjectTopology(Topo):
    def __init__(self, num_switches=3, **opts):
        self.num_switches = num_switches
        super().__init__(**opts)

    def build(self):
        # 1) Create switches in a line
        switches = []
        for i in range(1, self.num_switches + 1):
            sw = self.addSwitch(f's{i}', failMode='standalone')
            switches.append(sw)
 
        # 2) Create the four hosts (h1,h2 on left, h3,h4 on right)
        h1 = self.addHost('h1', ip='10.10.100.1/24')
        h2 = self.addHost('h2', ip='10.10.200.2/24')
        h3 = self.addHost('h3', ip='10.10.100.3/24')
        h4 = self.addHost('h4', ip='10.10.200.4/24')

        # 3) Link hosts to the *first* and *last* switch
        self.addLink(h1, switches[0])
        self.addLink(h2, switches[0])
        self.addLink(h3, switches[-1])
        self.addLink(h4, switches[-1])

        # 4) Chain the switches together
        for i in range(self.num_switches - 1):
            self.addLink(switches[i], switches[i + 1], cls=TCLink)


def run():
    # parse optional command-line arg
    num_sw = int(sys.argv[1]) if len(sys.argv) == 2 else 3

    topo = ProjectTopology(num_switches=num_sw)

    # point to your ONOS controller
    cont = RemoteController('onos', ip='172.17.0.2', port=6653)

    net = Mininet(
        topo=topo,
        controller=None,
        switch=OVSSwitch,
        host=CPULimitedHost,
        link=TCLink,
        autoSetMacs=True
    )
    net.addController(cont)
    net.start()

    info('*** Applying VLAN tagging and trunks\n')
    # After net.start(), iterate links to tag/access or trunk
    for link in net.links:
        n1, intf1 = link.intf1.node, link.intf1.name
        n2, intf2 = link.intf2.node, link.intf2.name

        # switch<->switch => trunk VLANs 100,200
        if isinstance(n1, OVSSwitch) and isinstance(n2, OVSSwitch):
            for sw, intf in ((n1, intf1), (n2, intf2)):
                sw.cmd(f'ovs-vsctl set port {intf} trunks=100,200')

        # host<->switch => access port, tag either 100 or 200
        else:
            host, sw, intf = (
                (n1, n2, intf2) if n1.name.startswith('h') else
                (n2, n1, intf1)
            )
            vlan = 100 if host.name in ('h1','h3') else 200
            sw.cmd(f'ovs-vsctl set port {intf} tag={vlan}')

    info('*** Setup complete; dropping to CLI\n')
    CLI(net)
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')
    run()
