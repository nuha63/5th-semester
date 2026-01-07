import socket
import struct
import threading
import time

MULTICAST_GROUP = "224.5.5.5"
PORT = 6060

TOTAL_ELECTORATES = 5  # total number of voters

received_votes = []     # all received votes including own
vote_sent = False       # to ensure 1 vote only

def receive_votes(sock):
    """Receive votes from multicast group"""
    global received_votes
    while True:
        data, addr = sock.recvfrom(1024)
        vote = data.decode().strip()

        if vote in ['A', 'B']:
            received_votes.append(vote)
            print(f"\n🟢 Received vote from {addr[0]}: {vote}")
            print(f"Current received votes: {received_votes}")

        if len(received_votes) == TOTAL_ELECTORATES:
            print("\nAll votes received!")
            declare_winner()
            break

def declare_winner():
    """Determine and print winner"""
    countA = received_votes.count('A')
    countB = received_votes.count('B')

    print("\n==============================")
    print("📊 FINAL VOTE RESULT")
    print(f"Votes for A: {countA}")
    print(f"Votes for B: {countB}")

    if countA > countB:
        print("🏆 Winner: Candidate A")
    elif countB > countA:
        print("🏆 Winner: Candidate B")
    else:
        print("🤝 It's a TIE!")
    print("==============================\n")


def main():
    global vote_sent, received_votes

    # Create UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("", PORT))

    # join multicast group
    mreq = struct.pack("4sl", socket.inet_aton(MULTICAST_GROUP), socket.INADDR_ANY)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)

    print("🟢 Joined election multicast group.")
    print("Cast your vote (A or B): ")

    # Start receiving thread
    threading.Thread(target=receive_votes, args=(sock,), daemon=True).start()

    # Get vote from user (only once)
    while not vote_sent:
        vote = input("Enter vote (A/B): ").strip().upper()

        if vote not in ['A', 'B']:
            print("❌ Invalid vote! Choose A or B only.")
            continue

        # Add own vote first
        received_votes.append(vote)

        # send vote to multicast group
        sock.sendto(vote.encode(), (MULTICAST_GROUP, PORT))
        print(f"📨 Vote '{vote}' sent to all electorates!")

        vote_sent = True

    # wait until all votes come
    while len(received_votes) < TOTAL_ELECTORATES:
        time.sleep(0.2)

    # winner will be declared in receive thread
    time.sleep(1)

if __name__ == "__main__":
    main()
