import socket

HOST = '127.0.0.1'
PORT = 5001

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen(1)
print("Server listening...")

conn, addr = server_socket.accept()
print(f"Connected by {addr}")

with open("received_file.txt", "wb") as f:
    while True:
        data = conn.recv(1024)
        if not data:
            break
        f.write(data)
        conn.sendall(b"ACK")  # acknowledgment পাঠানো হচ্ছে

conn.close()
print("File received successfully.")
