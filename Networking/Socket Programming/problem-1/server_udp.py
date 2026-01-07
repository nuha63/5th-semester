import socket

HOST = '127.0.0.1'
PORT = 5002

server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket.bind((HOST, PORT))
print("UDP Server listening...")

with open("received_udp.txt", "w") as f:
    while True:
        data, addr = server_socket.recvfrom(1024)
        if data == b"END":
            break
        f.write(data.decode())

print("File received successfully (UDP).")
