import socket
import struct
import threading

MULTICAST_GROUP = "224.1.1.1"   # Multicast Group IP
PORT = 5007                    # Port Number

def receive_messages(sock):
    """Receive messages from multicast group"""
    while True:
        try:
            data, addr = sock.recvfrom(1024)
            print(f"\n[{addr[0]}]: {data.decode()}")
        except:
            break

def main():
    # Create UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)

    # Allow multiple clients to use same address/port
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    # Bind the socket to the server address
    sock.bind(('', PORT))

    # Join multicast group
    mreq = struct.pack(
        "4sl",
        socket.inet_aton(MULTICAST_GROUP),
        socket.INADDR_ANY
    )
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)

    print("🟢 Joined multicast chat group.")
    print("Start chatting... (Press Ctrl+C to exit)\n")

    # Thread for receiving messages
    threading.Thread(target=receive_messages, args=(sock,), daemon=True).start()

    # Send messages
    while True:
        message = input("")
        if message.strip() == "":
            continue
        sock.sendto(message.encode(), (MULTICAST_GROUP, PORT))

if __name__ == "__main__":
    main()
