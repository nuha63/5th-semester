import socket

HOST = '127.0.0.1'
PORT = 5002

client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

filename = "sample.txt"
with open(filename, "r") as f:
    for line in f:
        client_socket.sendto(line.encode(), (HOST, PORT))

client_socket.sendto(b"END", (HOST, PORT))
print("File sent successfully (UDP).")