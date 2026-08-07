
import binascii
import socket
import struct
import sys
import hashlib
import random
import time

#The servers address and port number
UDP_IP = "127.0.0.1"
UDP_PORT = 5001

unpacker = struct.Struct('I I 8s 32s')
sendingPort = 6000 # a port to send acks to

#takes in a 3-tuple and returns the checksum for the tuple
def mk_chksum(values):
    UDP_Data = struct.Struct('I I 8s')
    packed_data = UDP_Data.pack(*values)
    return bytes(hashlib.md5(packed_data).hexdigest(), encoding="UTF-8")

#takes in a four tuple with the fourth value being the check sum for the first
# 3 entries in the tuple and returns a pseudo UDP Packet
def mk_packet(values_with_chksum):
    UDP_Packet_Data = struct.Struct('I I 8s 32s')
    return UDP_Packet_Data.pack(*values_with_chksum)

#Sends a pseudo UDP Packet to the target port, prints a message to the console
def send_pkt(UDP_Packet, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # UDP
    sock.sendto(UDP_Packet, (UDP_IP, port))
    print("Sent packet: ", unpacker.unpack(UDP_Packet))

#Checks if a given pseudo UDP Packet is corrupt by calculating the check sum of the first 3 entries
#and comparing it to the checksum provided in the fourth entry of the tuple
def notcorrupt(UDP_Packet):
    chksum = mk_chksum((UDP_Packet[0], UDP_Packet[1], UDP_Packet[2]))
    if UDP_Packet[3] == chksum:
        print('CheckSums Match, Packet OK')
        return True
    else:
        print('Checksums Do Not Match, Packet Corrupt')
        return False

#Switch the expected sequence number from one state to another
def switch_seq(expected_seq):
    if expected_seq == 0 :
        return 1
    else:
        return 0

#Given a pseudo UDP Packet and a sequence number, this function returns true if the given packet
# has the given sequence number and false otherwise, prints a message to the console with the results
def has_seq(UDP_Packet,num):
    if UDP_Packet[1] == num:
        print('Packet has correct sequence number: seq =', num)
        return True
    else:
        print('Packet has incorrect sequence number: seq =', switch_seq(num))
        return False

#Simply implements the extract data function reffered to in rdt 3.0
def extract(UDP_Packet):
    return UDP_Packet[2]

#Implements the deliver data function in rdt 3.0
#printing the recieved data to a string
def deliver(data):
    string = data.decode("utf-8")
    print("Recieved data:", string + ", succesfully delivered upwards")

#Network Delay, 1/3 chance of delaying an ack
def Network_Delay():
    if True and random.choice([0,1,0]) == 1:
        time.sleep(.01)
        print("Packet Delayed ")
    else:
        print("Packet Sent ")

#Network Loss, 2/5 chance of loosing an ack
def Network_Loss():
    if True and random.choice([0,1,0,1,0]) == 1:
        print("Packet Lost ")
        return(1)
    else:
        return(0)

#Packet corrupter, 2/5 chance of corrupting an ack
def Packet_Checksum_Corrupter(packetdata):
     if True and random.choice([0,1,0,1,0]) == 1:
        return(b'Corrupt!')
     else:
        return(packetdata)


#Create the socket and listen
sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))

expected_seq = 0 #starting sequence number
ack_msg = b'ACK__ACK' #Standard Ack message that the server will send with each ack

#Listen for client requests
while True:

    #Receive Data
    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
    UDP_Packet = unpacker.unpack(data)
    print("received from:", addr)
    print("received message:", UDP_Packet)

    #Check if the recieved packet has been corrupted and has the correct sequence number
    if notcorrupt(UDP_Packet) and has_seq(UDP_Packet, expected_seq):

        #recieve and deliver data upwards
        data = extract(UDP_Packet)
        deliver(data)

        #when network loss occurs the ack does not get sent
        #other wise send the correct ack
        if not Network_Loss():
            chksum = mk_chksum((1, expected_seq, ack_msg))

            #2/5 chance of an incorrect checksum being sent
            packet = mk_packet((1, expected_seq, ack_msg, Packet_Checksum_Corrupter(chksum)))

            #1/3 chance the ack is sent late
            Network_Delay()
            send_pkt(packet, sendingPort)
            expected_seq = switch_seq(expected_seq) #switch states

    #packet is corrupt or has wrong seq, send ack with previous states sequence number
    else:
        if not Network_Loss():
            chksum = mk_chksum((1, switch_seq(expected_seq), ack_msg))

            # 2/5 chance of an incorrect checksum being sent
            packet = mk_packet((1, switch_seq(expected_seq), ack_msg, Packet_Checksum_Corrupter(chksum)))

            # 1/3 chance the ack is sent late
            Network_Delay()
            send_pkt(packet, sendingPort)

    print("\n")

#Note Please make sure server is running before client sends requests;
#otherwise you will be met with an infinite timeout loop

