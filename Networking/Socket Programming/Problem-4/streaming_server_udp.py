import socket
import os
import random
import time

HOST = "127.0.0.1"
PORT = 7070

server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind((HOST, PORT))

print("UDP Streaming Server Running...")

while True:
    filename, client_addr = server.recvfrom(1024)
    filename = filename.decode()

    print(f"Client requested: {filename}")

    if not os.path.isfile(filename):
        server.sendto(b"ERROR: File not found", client_addr)
        continue

    with open(filename, "rb") as f:
        while True:
            chunk_size = random.randint(1000, 2000)
            data = f.read(chunk_size)
            if not data:
                break

            server.sendto(data, client_addr)
            time.sleep(0.05)   # Smooth streaming

    server.sendto(b"STREAM_END", client_addr)

    print("File streaming completed.\n")
