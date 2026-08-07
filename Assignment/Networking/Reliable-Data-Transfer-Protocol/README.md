# Reliable Data Transfer Protocol

This project implements the reliable data transfer 3.0 protocol discussed in
section 3.4.1 of Computer Networking: A Top-Down Approach [1]. The purpose of this project
was to gain experience with network programming.

It contains two applications, **UDP_Clinet.py** and **UDP_Server.py**, which
communicate over a network which experiences corruption, delays, and packet loss.
The implementation uses the local loopback address to send and recieve packets.
The packets sent mirror that of a UDP Packet, reffered to as pseudo UDP packets.

Pseudo UDP packets contain the following data:
- ACK – Indicates if packet is ACK or not. Valid values (1 or 0)
- SEQ – Sequence number of packet. Valid values (1 or 0)
- DATA – Application Data (8 bytes)
- CHKSUM – MD5 Checksum of packet (32 Bytes)

**UDP_Client.py** connects to **UDP_Server.py** via UDP, and sends 3 seperate packets through a
fixed port number.

**UDP_Server.py** establishes a UDP socket and listens for connections from clients. 
The functions Network_Loss, Network_Delay, and Packet_Checksum_Corrupter are called on the server
side to simulate an unreliable network.

Both **UDP_Client.py** and **UDP_Server.py** output a line of text for each of the following actions:
- Received Packet (with all packet values shown)
- Packet Checksum Compare Result (ie. Corrupt or not corrupt)
- Sent Packet (with all packet values shown)
- Timer Expired

Lastly, the below images describe the reliable data transfer 3.0 protocol and how it handles
corruption, delays, and losses.

![Sender State Diagram](https://github.com/RyanSandford/Reliable-Data-Transfer-Protocol/blob/master/rdt%203.0%20Sender.jpg)
![Reciever State Diagram](https://github.com/RyanSandford/Reliable-Data-Transfer-Protocol/blob/master/rdt%203.0%20Receiver.jpg)
![rdt 3.0 cases](https://github.com/RyanSandford/Reliable-Data-Transfer-Protocol/blob/master/rdt%203.0%20visualization.jpg)

[1] Computer Networking: A Top-Down Approach
James F. Kurose and Keith W. Ross
Pearson, 7th Edition, 2016
ISBN: 978-0-13-359414-0
