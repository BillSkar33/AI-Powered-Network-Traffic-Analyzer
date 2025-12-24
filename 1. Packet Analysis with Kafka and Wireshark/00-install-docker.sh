#!/bin/bash

# Χρώματα για καλύτερη εμφάνιση
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ξεκινώντας την εγκατάσταση του Docker Engine ===${NC}"

# 1. Έλεγχος αν το Docker υπάρχει ήδη
if [ -x "$(command -v docker)" ]; then
    echo -e "${YELLOW}[!] Το Docker φαίνεται να είναι ήδη εγκατεστημένο.${NC}"
    docker --version
    echo -e "${YELLOW}Αν θέλεις επανεγκατάσταση, αφαίρεσέ το πρώτα.${NC}"
    exit 0
fi

# 2. Ενημέρωση συστήματος και εγκατάσταση προαπαιτούμενων
echo -e "${GREEN}[+] Ενημέρωση πακέτων συστήματος...${NC}"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 3. Προσθήκη του επίσημου GPG κλειδιού
echo -e "${GREEN}[+] Προσθήκη GPG Key...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Προσθήκη του Repository
echo -e "${GREEN}[+] Προσθήκη Docker Repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Εγκατάσταση Docker Packages
echo -e "${GREEN}[+] Εγκατάσταση Docker Engine & Compose...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Ρύθμιση Δικαιωμάτων Χρήστη (Το πιο σημαντικό βήμα)
echo -e "${GREEN}[+] Ρύθμιση δικαιωμάτων χρήστη ($USER)...${NC}"
sudo usermod -aG docker $USER

echo -e "${GREEN}=== Η εγκατάσταση ολοκληρώθηκε! ===${NC}"
echo -e "${RED}!!! ΠΡΟΣΟΧΗ !!!${NC}"
echo -e "Για να εφαρμοστούν τα δικαιώματα και να τρέχεις docker χωρίς 'sudo', πρέπει να κάνεις:"
echo -e "1. ${YELLOW}Log out και Log in${NC} από τα Windows/Ubuntu, Ή"
echo -e "2. Τρέξε τώρα την εντολή: ${YELLOW}newgrp docker${NC}"