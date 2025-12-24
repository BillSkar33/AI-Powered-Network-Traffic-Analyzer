import time
import requests
import socket
import random
import multiprocessing
import os

# Πόσους "ψεύτικους" κόμβους θέλουμε να τρέξουν ταυτόχρονα;
NUM_NODES = 10  # Θα ανοίξει 10 παράλληλες διεργασίες (σαν 10 pc)

TARGET_URL = "http://httpbin.org"
TARGET_IP = "8.8.8.8"

def traffic_generator(node_id):
    """
    Αυτή η συνάρτηση τρέχει ξεχωριστά για κάθε Node.
    """
    print(f"🟢 Node-{node_id} started (PID: {os.getpid()})")
    
    while True:
        try:
            # 1. Web Traffic (HTTP)
            endpoints = ["/get", "/ip", "/user-agent", "/headers"]
            url = f"{TARGET_URL}{random.choice(endpoints)}"
            requests.get(url, timeout=2)
            
            # 2. Port Scan (TCP) - Γρήγορο χτύπημα
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.5)
            sock.connect_ex((TARGET_IP, 53))
            sock.close()

            # Μικρή καθυστέρηση για να μην κρασάρει το laptop σου (αλλά αρκετή για θόρυβο)
            time.sleep(random.uniform(0.1, 0.5))
            
        except Exception:
            pass # Αν αποτύχει κάτι, απλά συνέχισε (όπως ένα botnet)

if __name__ == "__main__":
    print(f"🚀 Starting Stress Test with {NUM_NODES} concurrent nodes...")
    print("⚠️  Warning: This will generate HEAVY network traffic.")
    print("Press Ctrl+C to stop all nodes.\n")

    processes = []
    
    try:
        # Δημιουργία και εκκίνηση των processes
        for i in range(NUM_NODES):
            p = multiprocessing.Process(target=traffic_generator, args=(i+1,))
            p.start()
            processes.append(p)
        
        # Κρατάμε το script ζωντανό
        for p in processes:
            p.join()
            
    except KeyboardInterrupt:
        print("\n🛑 Stopping all nodes...")
        for p in processes:
            p.terminate()
        print("Done.")