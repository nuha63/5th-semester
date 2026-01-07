import socket
import threading
import os
import time

HOST = "127.0.0.1"
PORT = 7070

client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

filename = input("Enter multimedia file name (mp3/mp4/wav etc.): ")
client.sendto(filename.encode(), (HOST, PORT))

output_file = "received_" + filename

file = open(output_file, "wb")

streaming = True
first_play_started = False

def background_player():
    global first_play_started

    # Wait until minimum 50 KB downloaded
    while os.path.getsize(output_file) < 50 * 1024:
        time.sleep(0.2)

    first_play_started = True
    print("\nLaunching media player...\n")

    # Windows default media player
    os.startfile(output_file)

player_thread = threading.Thread(target=background_player)
player_thread.start()

while streaming:
    data, addr = client.recvfrom(4096)
    
    if data == b"STREAM_END":
        streaming = False
        break

    file.write(data)

file.close()
print("Streaming Finished. File saved as:", output_file)

client.close()
