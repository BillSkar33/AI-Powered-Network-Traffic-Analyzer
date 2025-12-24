#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Installing Wireshark (Tshark) & Python dependencies...${NC}"

# 1. Εγκατάσταση Tshark και Python Virtual Environment
sudo apt update
sudo apt install -y tshark python3-venv

# 2. Ρύθμιση Δικαιωμάτων για να τρέχει χωρίς sudo
# (Προσοχή: Στο παράθυρο που θα βγει, πάτα "YES")
echo -e "${GREEN}[+] Configuring Wireshark permissions...${NC}"
sudo dpkg-reconfigure wireshark-common
sudo usermod -aG wireshark $USER

# 3. Δημιουργία Python Virtual Environment (για να μην χαλάσουμε το σύστημα)
echo -e "${GREEN}[+] Setting up Python Environment...${NC}"
python3 -m venv venv

# 4. Εγκατάσταση της βιβλιοθήκης Kafka για Python
echo -e "${GREEN}[+] Installing Kafka Python library...${NC}"
./venv/bin/pip install kafka-python-ng

echo -e "${GREEN}=== ΕΤΟΙΜΟ! ===${NC}"
echo -e "Για να πιάσουν οι ρυθμίσεις του Wireshark, πρέπει να κάνεις:"
echo -e "1. ${GREEN}Log out και Log in${GREEN} από το Ubuntu, Ή"
echo -e "2. Τρέξε: ${GREEN}newgrp wireshark${NC}"