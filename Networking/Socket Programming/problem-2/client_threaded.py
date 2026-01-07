import socket

HOST = "127.0.0.1"
PORT = 5050

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((HOST, PORT))

file_name = input("Enter file name to download: ")

client.sendall(file_name.encode())

# Output file name
output_file = "downloaded_" + file_name

with open(output_file, "wb") as f:
    while True:
        data = client.recv(1024)
        if not data:
            break
        f.write(data)

print("File downloaded successfully as", output_file)
client.close()