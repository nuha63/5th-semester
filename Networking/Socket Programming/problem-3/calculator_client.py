import socket

HOST = "127.0.0.1"
PORT = 6060

a = input("Enter first number: ")
b = input("Enter second number: ")
op = input("Enter operator (+, -, *, /, %): ")

message = f"{a} {b} {op}"

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((HOST, PORT))

client.send(message.encode())

result = client.recv(1024).decode()
print("Result:", result)

client.close()