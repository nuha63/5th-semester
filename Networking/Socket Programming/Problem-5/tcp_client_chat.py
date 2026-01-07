import socket

HOST = "127.0.0.1"
PORT = 8081

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((HOST, PORT))

print("Connected to TCP Chat Server")

try:
    while True:
        # Client message
        msg = input("You: ")
        client.sendall(msg.encode())

        # Receive reply
        reply = client.recv(1024).decode()
        print("Server:", reply)

except KeyboardInterrupt:
    print("\nChat closed.")
    client.close()
