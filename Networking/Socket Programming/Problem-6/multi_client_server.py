import socket
import threading

HOST = "127.0.0.1"
PORT = 9090

def handle_client(conn, addr):
    print(f"[CONNECTED] Client: {addr}")

    try:
        while True:
            # Receive message
            data = conn.recv(1024).decode()
            if not data:
                break
            print(f"Client {addr}: {data}")

            # Server reply
            reply = input(f"You → {addr}: ")
            conn.sendall(reply.encode())

    except:
        print(f"[ERROR] Connection lost with {addr}")

    finally:
        conn.close()
        print(f"[DISCONNECTED] Client {addr} closed")


server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((HOST, PORT))
server.listen(5)

print(f"[SERVER STARTED] Listening on {HOST}:{PORT}")

try:
    while True:
        conn, addr = server.accept()
        
        thread = threading.Thread(target=handle_client, args=(conn, addr))
        thread.start()

        print(f"[ACTIVE CLIENTS] {threading.active_count() - 1}")

except KeyboardInterrupt:
    print("\nServer shutting down...")
    server.close()
