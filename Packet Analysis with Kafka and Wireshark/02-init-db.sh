#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Connecting to MariaDB container to initialize Schema...${NC}"

# Η εντολή SQL που θα τρέξει
SQL_COMMANDS="
USE network_traffic_db;

DROP TABLE IF EXISTS ai_threat_logs;
DROP TABLE IF EXISTS traffic_logs;

CREATE TABLE traffic_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    source_ip VARCHAR(45) NOT NULL,
    source_port INT,
    dest_ip VARCHAR(45) NOT NULL,
    dest_port INT,
    protocol VARCHAR(20),
    length INT,
    info TEXT,
    is_suspicious BOOLEAN DEFAULT FALSE
);

CREATE TABLE ai_threat_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    log_id BIGINT NOT NULL,
    ai_explanation TEXT,
    suggested_action VARCHAR(255),
    severity_level VARCHAR(20),
    FOREIGN KEY (log_id) REFERENCES traffic_logs(id) ON DELETE CASCADE
);

INSERT INTO traffic_logs (source_ip, source_port, dest_ip, dest_port, protocol, length, info, is_suspicious)
VALUES ('192.168.1.50', 44322, '10.0.0.1', 22, 'TCP', 64, 'Possible SSH Brute Force', TRUE);

SET @last_id = LAST_INSERT_ID();

INSERT INTO ai_threat_logs (log_id, ai_explanation, suggested_action, severity_level)
VALUES (@last_id, 'Pattern matches known brute-force attack signature on SSH port.', 'Block Source IP', 'HIGH');
"

# Εκτέλεση μέσα στο container
docker exec -i network_mariadb mariadb -u user -password=password <<< "$SQL_COMMANDS"

echo -e "${GREEN}[+] Database Schema created and Test Data inserted!${NC}"