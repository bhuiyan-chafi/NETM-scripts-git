import random
import math
import time
import logging
from scapy.all import send
from scapy.layers.inet import IP
from scapy.layers.l2 import Ether
from scapy.packet import Raw

lambda_arrival = 10  # Intensity of arrivals (packets per second)
lambda_length = 0.0025  # Intensity of length (packets per byte) thus average length 1/lambda_length

def generate_packet_length():
    return int(-math.log(1.0 - random.random()) / lambda_length)

# Generates packets with exponential distributed inter-arrival time and length
def generate_packets():
    logging.getLogger("scapy").setLevel(logging.CRITICAL)

    generated_packets = 0
    generated_bytes = 0

    while True:
	# Interarrival time
        interarrival_time = random.expovariate(lambda_arrival)
        time.sleep(interarrival_time)

        # Packet size - float value is truncated (+1 to compensate), then effective length is higher than theory
        packet_length = random.expovariate(lambda_length)
        packet_bytes = int(packet_length)

        # IP packet creation with SCAPY - proto is required otherwise wireshark does not recognize the packet
        # Python strings with b"..." are interpreted as strings of bytes
        packet = IP(src="10.0.2.15", dst="10.0.2.2", proto=253)/Raw(load=b"A" * packet_bytes)
        
        # Send packet using SCAPY
        send(packet, iface="enp0s3", verbose=False)

        generated_packets = generated_packets + 1
        generated_bytes = generated_bytes + packet_bytes
        generated_average_length = str("{:.2f}".format(generated_bytes / generated_packets))

        print("Actual packet " + str(packet_bytes) + " bytes - current average length: " + generated_average_length + " bytes")

# Avvia la generazione dei pacchetti
print("Expected average packet length (theoretical value):", 1/lambda_length)
generate_packets()

