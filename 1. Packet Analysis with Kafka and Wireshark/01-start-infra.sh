#!/bin/bash

# Χρώματα για να φαίνεται ωραίο στο τερματικό
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+] Checking Docker installation...${NC}"
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

echo -e "${GREEN}[+] Starting Infrastructure (Kafka, Spark, MariaDB)...${NC}"
# Ξεκινάει τα containers στο background
docker compose up -d

echo -e "${GREEN}[+] Waiting for services to initialize (20 seconds)...${NC}"
# Περιμένουμε λίγο γιατί η βάση θέλει χρόνο να σηκωθεί
sleep 20

echo -e "${GREEN}[+] Infrastructure is UP! Check http://localhost:8090 for Kafka UI.${NC}"