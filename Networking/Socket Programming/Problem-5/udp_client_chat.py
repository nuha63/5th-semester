import socket

HOST = "127.0.0.1"
PORT = 9091

client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

print("UDP Chat Client Started")

try:
    while True:
        msg = input("You: ")
        if len(msg) > 1000:
            msg = msg[:1000]

        client.sendto(msg.encode(), (HOST, PORT))

        reply, addr = client.recvfrom(1024)
        print("Server:", reply.decode())

except KeyboardInterrupt:
    print("\nChat closed.")
    client.close()
