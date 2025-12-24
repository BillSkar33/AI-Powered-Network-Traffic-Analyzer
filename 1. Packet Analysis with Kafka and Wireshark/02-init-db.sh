#!/bin/bash

# Περιμένουμε λίγο να σηκωθεί η βάση
echo "⏳ Waiting for MariaDB to be ready..."
sleep 10

echo "🚀 Initializing Database Schema..."

# Εντολή SQL που δημιουργεί ΑΚΡΙΒΩΣ τους πίνακες του README
# Χρησιμοποιούμε 'IF NOT EXISTS' για να μην βγάλει λάθος αν υπάρχουν ήδη
docker exec -i network_mariadb mariadb -uuser -ppassword network_traffic_db <<EOF
-- Table 1: Traffic Logs
CREATE TABLE IF NOT EXISTS traffic_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    source_ip VARCHAR(45) NOT NULL,
    source_port INT,
    dest_ip VARCHAR(45) NOT NULL,
    dest_port INT,
    protocol VARCHAR(20),
    length INT,
    info TEXT,
    is_suspicious BOOLEAN DEFAULT FALSE,
    INDEX idx_source_ip (source_ip),
    INDEX idx_event_time (event_time),
    INDEX idx_protocol (protocol),
    INDEX idx_suspicious (is_suspicious)
) ENGINE=InnoDB;

-- Table 2: AI Threat Logs
CREATE TABLE IF NOT EXISTS ai_threat_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    log_id BIGINT NOT NULL,
    ai_explanation TEXT,
    suggested_action VARCHAR(255),
    severity_level VARCHAR(20),
    FOREIGN KEY (log_id) REFERENCES traffic_logs(id) ON DELETE CASCADE,
    INDEX idx_severity (severity_level)
) ENGINE=InnoDB;

EOF

echo "✅ Database Schema created successfully!"
echo "   - Created table: traffic_logs"
echo "   - Created table: ai_threat_logs"
