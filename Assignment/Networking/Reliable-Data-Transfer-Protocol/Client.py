
import binascii
import socket
import struct
import sys
import hashlib

#Target port and IP to send messages too
UDP_IP = "127.0.0.1"
UDP_PORT = 5000


unpacker = struct.Struct('I I 8s 32s')
listeningPort = 6001 #Port to recieve acks from
interval = 0.009 #timeout interval
expected_seq = 0 #the expected sequence number of the next ack

print("UDP target IP:", UDP_IP)
print("UDP target port:", UDP_PORT)
print("\n")

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
    sock.sendto(UDP_Packet, (UDP_IP, UDP_PORT))
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

#Given a pseudo UDP Packet and a sequence number, this function returns true if the given packet
#is an acknowledgment and has the given sequence number and false otherwise, prints a message to the console
# with the results
def isAck(rcvdPacket, num):

    #if rcvdPacket is an ack and has the required sequence number
    if rcvdPacket[0] == 1 and rcvdPacket[1] == num:
        print("Recieved acknowldegment with correct seq num", num)
        return True
    else:
        print("Recieved acknowldegment with incorrect seq num", switch_seq(num))
        return False

#Switch the expected sequence number from one state to another
def switch_seq(expected_seq):
    if expected_seq == 0 :
        return 1
    else:
        return 0

#Listens for an ack from the server
def listen_for_ack():
    flag = True
    global expected_seq
    while flag:
        data, addr = sock.recvfrom(1024)  # buffer size is 1024 bytes
        rcvd_packet = unpacker.unpack(data)
        print("received from:", addr)
        print("received message:", rcvd_packet)

        #if the receieved packet is not corrupt, an ack, and has the correct sequence number,
        # than switch states and exit the loop
        #returns 1 when a proper acknowledgment has been recieved
        if (notcorrupt(rcvd_packet)) and (isAck(rcvd_packet, expected_seq)):
            expected_seq = switch_seq(expected_seq)
            flag = False
            return 1


#Create the socket and listen
sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, listeningPort))
sock.settimeout(interval) #set the timeout interval for the socket

#A list of messages the client wants to send the server
messages = [bytes('NCC-1701', 'utf-8'), bytes('NCC-1422', 'utf-8'), bytes('NCC-1017', 'utf-8')]

#The main part of the client cokde where the client sends messages to the server
#and waits for a response
for m in messages:
    print("Sending Message:", m.decode("utf-8"))
    while True:

        #Send message and listen for response from server
        try:

            #send message to server
            chksum = mk_chksum((0, expected_seq, m))
            UDP_Packet = mk_packet((0, expected_seq, m, chksum))
            send_pkt(UDP_Packet, UDP_PORT)

            #once a proper ack has been recieved, exit loop and send next message
            if (listen_for_ack() == 1):
                print("\n")
                break

        #When a timeout occurs reset the timer, on the next iteration of the loop the
        # message will be resent
        except socket.timeout:
            print("timer expired, resending packet")
            sock = socket.socket(socket.AF_INET,  # Internet
                                 socket.SOCK_DGRAM)  # UDP
            sock.bind((UDP_IP, listeningPort))
            sock.settimeout(interval)

#Note: on some uncommon occasions a correct ack will be sent by the server but client will timeour
#before processing such an ack, this is not a fault in the implementation of the protocol, likewise
# the program behaves as expected when this timeout occurs (ie resending the message which the server then discards
# and sends a duplicate ack
