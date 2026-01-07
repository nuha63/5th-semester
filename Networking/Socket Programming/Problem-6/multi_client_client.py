import socket

HOST = "127.0.0.1"
PORT = 9090

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((HOST, PORT))

print("Connected to chat server.")

try:
    while True:
        msg = input("You: ")
        client.sendall(msg.encode())

        reply = client.recv(1024).decode()
        print("Server:", reply)

except KeyboardInterrupt:
    print("\nChat closed.")
    client.close()
