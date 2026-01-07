import socket
import threading
import time
import os

HOST = "127.0.0.1"
PORT = 5050

def handle_client(conn, addr):
    print(f"[THREAD STARTED] Client connected: {addr}")

    try:
        filename = conn.recv(1024).decode()
        print(f"Client requested: {filename}")

        if not os.path.isfile(filename):
            conn.sendall(b"ERROR: File not found")
            conn.close()
            return

        with open(filename, "rb") as f:
            while True:
                chunk = f.read(1000)
                if not chunk:
                    break

                conn.sendall(chunk)
                time.sleep(0.2)     # 200 ms sleep

        print(f"[SENT] File transfer completed for {addr}")

    except Exception as e:
        print("Error:", e)

    finally:
        conn.close()
        print(f"[THREAD CLOSED] {addr}")

def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen(5)

    print(f"[STARTED] Server running on {HOST}:{PORT}")

    while True:
        conn, addr = server.accept()
        thread = threading.Thread(target=handle_client, args=(conn, addr))
        thread.start()
        print(f"[ACTIVE THREADS] {threading.active_count() - 1}")

start_server()