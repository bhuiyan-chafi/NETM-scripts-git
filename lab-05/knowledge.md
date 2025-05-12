# If you are having issues with basic mininet topology

    sudo mn

Says port is already busy with another process. Run this command to stop the controller.
sudo killall ovs-

# If you have created a topolgy and then trying another one

The issue is you can see the topology but cannot do

    mininet> pingall

the reason is, your controller is occupied with past topology setup. Follow the steps:

    1. mininet>exit
    2. sudo mn -c
    3. karaf@root> logout
    4. sudo ./controller-restart.sh

Then try the new topology.
