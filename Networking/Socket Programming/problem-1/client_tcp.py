import socket
import os
import time

HOST = '127.0.0.1'
PORT = 5001

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((HOST, PORT))

filename = "sample.txt"
file_size = os.path.getsize(filename)
print(f"Sending '{filename}' ({file_size} bytes)")

with open(filename, "rb") as f:
    while True:
        chunk = f.read(100)
        if not chunk:
            break

        while True:
            client_socket.sendall(chunk)
            client_socket.settimeout(2.0)  # 2 sec timeout
            try:
                ack = client_socket.recv(1024)
                if ack == b"ACK":
                    break  # acknowledgment পাওয়া গেছে
            except socket.timeout:
                print("Timeout! Retransmitting chunk...")

client_socket.close()
print("File sent successfully.")
