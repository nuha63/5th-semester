import socket

HOST = "127.0.0.1"
PORT = 8081

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((HOST, PORT))
server.listen(1)

print("TCP Chat Server Running...")
conn, addr = server.accept()
print("Connected with:", addr)

try:
    while True:
        # Receive message
        msg = conn.recv(1024).decode()
        print("Client:", msg)

        # Server reply
        reply = input("You: ")
        conn.sendall(reply.encode())

except KeyboardInterrupt:
    print("\nChat closed.")
    conn.close()
    server.close()
