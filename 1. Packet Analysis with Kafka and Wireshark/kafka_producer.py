import sys
import json
from kafka import KafkaProducer

# Ρύθμιση του Producer
producer = KafkaProducer(
    bootstrap_servers=['127.0.0.1:9092'],
    value_serializer=lambda x: json.dumps(x).encode('utf-8')
)

TOPIC_NAME = 'network-traffic'

print(f"[*] Starting Kafka Producer. Sending data to topic: {TOPIC_NAME}")

# Διαβάζουμε το Standard Input (το pipe από το Tshark)
for line in sys.stdin:
    try:
        line = line.strip()
        
        # Το Tshark -T json βγάζει array ([...]). Εμείς θέλουμε καθαρά αντικείμενα.
        # Αγνοούμε την αρχή "[" και το τέλος "]"
        if line == "[" or line == "]":
            continue
            
        # Αφαιρούμε το κόμμα στο τέλος της γραμμής αν υπάρχει (π.χ. "},")
        if line.endswith(","):
            line = line[:-1]
            
        # Προσπαθούμε να το κάνουμε parse ως JSON για να δούμε αν είναι έγκυρο
        json_data = json.loads(line)
        
        # Αποστολή στον Kafka
        producer.send(TOPIC_NAME, value=json_data)
        
        # Τυπώνουμε μια τελεία για κάθε πακέτο (για να βλέπουμε ότι κινείται)
        print(".", end="", flush=True)
        
    except json.JSONDecodeError:
        # Αν η γραμμή δεν είναι JSON, την αγνοούμε
        pass
    except Exception as e:
        print(f"\n[!] Error: {e}")

print("\n[!] Stream ended.")