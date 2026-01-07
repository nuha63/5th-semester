import socket

HOST = "127.0.0.1"
PORT = 9091

server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind((HOST, PORT))

print("UDP Chat Server Running...")

try:
    while True:
        msg, client_addr = server.recvfrom(1024)
        print("Client:", msg.decode())

        reply = input("You: ")
        if len(reply) > 1000:
            reply = reply[:1000]   # Max limit
            
        server.sendto(reply.encode(), client_addr)

except KeyboardInterrupt:
    print("\nChat closed.")
    server.close()
