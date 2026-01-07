import socket

HOST = "127.0.0.1"
PORT = 6060

def calculate(a, b, op):
    a = int(a)
    b = int(b)

    if op == '+':
        return a + b
    elif op == '-':
        return a - b
    elif op == '*':
        return a * b
    elif op == '/':
        return a / b if b != 0 else "Error: Division by zero"
    elif op == '%':
        return a % b if b != 0 else "Error: Modulus by zero"
    else:
        return "Invalid Operator"

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((HOST, PORT))
server.listen(5)

print(f"Server running on {HOST}:{PORT}")

while True:
    conn, addr = server.accept()
    print("Connected by", addr)

    data = conn.recv(1024).decode()

    if not data:
        conn.close()
        continue

    a, b, op = data.split()

    result = calculate(a, b, op)
    conn.send(str(result).encode())

    conn.close()
