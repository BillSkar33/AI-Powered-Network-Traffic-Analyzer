#!/bin/bash

# 1. Εντοπισμός της ενεργής κάρτας δικτύου (π.χ. ens33, eth0, wlan0)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

# Αν δεν βρει κάρτα, βάζει "any" για ασφάλεια
if [ -z "$INTERFACE" ]; then
    INTERFACE="any"
fi

echo "--- Network Traffic Pipeline ---"
echo "📡 Interface detected: $INTERFACE"
echo "🎯 Target Kafka Topic: network-traffic"
echo "🛑 Press Ctrl+C to stop."
echo "------------------------------"

# 2. Η ΕΝΤΟΛΗ PIPELINE
# -i $INTERFACE : Η κάρτα που βρήκαμε αυτόματα
# -T ek         : Newline Delimited JSON (Κάθε πακέτο = μία γραμμή). Κρίσιμο για την Python!
# -e ...        : Ζητάμε συγκεκριμένα πεδία για να μην γεμίζει σκουπίδια το Kafka
sudo tshark -i "$INTERFACE" -l -T ek \
    -e frame.number \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    -e udp.srcport \
    -e udp.dstport \
    -e _ws.col.Protocol \
    -e frame.len \
    -e _ws.col.Info \
    | ./venv/bin/python kafka_producer.py
