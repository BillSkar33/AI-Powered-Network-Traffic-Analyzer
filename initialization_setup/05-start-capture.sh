#!/bin/bash

# Εντοπισμός της κύριας κάρτας δικτύου (συνήθως eth0 ή wlan0 ή enp...)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

echo "--- Network Traffic Pipeline ---"
echo "Interface detected: $INTERFACE"
echo "Target Kafka Topic: network-traffic"
echo "Press Ctrl+C to stop."
echo "------------------------------"

# Η ΕΝΤΟΛΗ "PIPE"
# 1. tshark -i $INTERFACE : Άκου σε αυτή την κάρτα
# 2. -l : Line buffered (στείλε τα δεδομένα αμέσως, μην περιμένεις να γεμίσει buffer)
# 3. -T json : Μορφή JSON
# 4. | : Στείλε το αποτέλεσμα στην επόμενη εντολή
# 5. python kafka_producer.py : Το script που τα στέλνει στον Kafka

tshark -i $INTERFACE -l -T json | ./venv/bin/python kafka_producer.py