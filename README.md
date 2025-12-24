# AI-Powered-Network-Traffic-Analyzer
An enterprise-grade data pipeline for real-time network traffic analysis. This project captures network packets, processes them via Apache Kafka and Spark Streaming, stores them in MariaDB, and uses Generative AI (OpenAI/LLM) to detect and explain security threats in plain language.

# 🛡️ Network Traffic Intelligence Pipeline

### Real-Time Packet Analysis with Kafka, Spark, and Generative AI

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [System Architecture](#-system-architecture)
3. [Initialization & Setup](#-initialization-&-setup)
4. [Infrastructure & Configuration](#-infrastructure-&-configuration-(docker-compose))
5. [Docker Command Reference](#-docker-command-reference)
6. [Database Layer (MariaDB)](#-database-layer-(mariaDB))
7. [Wireshark to Kafka](#-data-ingestion-layer-(wireshar-to-kafka))

---

## 🔭 Project Overview

This project implements an enterprise-grade **Data Engineering & Cybersecurity Pipeline**. It is designed to ingest high-volume network traffic data (from Wireshark/Tshark), process it in real-time, and utilize **Generative AI** to detect, analyze, and explain potential security threats in natural language.

**Key Capabilities:**

* **Ingestion:** Real-time packet streaming via Apache Kafka.
* **Processing:** Stream filtering and aggregation using Apache Spark.
* **Storage:** Structured persistence of logs and threat analysis in MariaDB.
* **Intelligence:** Integration with LLMs (OpenAI/Ollama) to explain *why* a packet is suspicious.

---

## 🏗️ System Architecture

The system follows a **Microservices Event-Driven Architecture**, fully containerized using Docker.

![System Architecture Diagram](/images/architecture_diagram.jpg)

### Data Flow Pipeline

1. **Source:** `Tshark` captures packets from the network interface and converts them to JSON.
2. **Buffer:** Packets are pushed to a **Kafka Topic** (`network-traffic`), acting as a high-throughput buffer.
3. **Processing:** **Spark Streaming** consumers read from Kafka, filter noise (e.g., standard ARP/broadcasts), and identify anomalies.
4. **Persistence:** Filtered logs are written to **MariaDB**.
5. **Analysis:** The Application Layer (Spring Boot) queries the DB and sends suspicious payloads to the **GenAI Model** for security assessment.

---

## 🚀 Initialization & Setup

The entire infrastructure is automated using Bash scripts located in the root directory. **Do not run manual Docker commands for the initial setup; use the scripts below.**

### Step 0: Environment Preparation

* **File:** `00-install-docker.sh`
* **Purpose:** Checks for Docker installation. If missing, it installs Docker Engine, Docker Compose, and configures user permissions (rootless mode).
* **Usage:** Run this only once on a fresh machine.

### Step 1: Start Infrastructure

* **File:** `01-start-infra.sh`
* **Purpose:** Orchestrates the deployment of the `docker-compose.yml` file. It starts Kafka, Zookeeper, Spark, and MariaDB in detached mode and performs health checks.
* **Usage:** Run this every time you want to start working on the project.

### Step 2: Database Initialization

* **File:** `02-init-db.sh`
* **Purpose:** Connects to the active MariaDB container, drops existing schemas (if any), creates the relational tables (`traffic_logs`, `ai_threat_logs`), and injects mock test data to verify persistence.
* **Usage:** Run this only after Step 1 is complete and healthy.

### ⚡ Quick Start: From 0 to Hero

Execute the following commands in order to set up the entire environment:


#### 1. Give execution permissions to scripts
```bash
chmod +x 00-install-docker.sh 01-start-infra.sh 02-init-db.sh
```
#### 2. Install Docker (Run only once on fresh machine)
```bash
./00-install-docker.sh
```
#### 3. Start Infrastructure (Kafka, Spark, MariaDB)
```bash
./01-start-infra.sh
```
#### 4. Initialize Database Schema & Test Data
```bash
./02-init-db.sh
```
---

## 🐳 Infrastructure & Configuration (Docker Compose)

The `docker-compose.yml` defines the following services. Use these credentials to connect external tools (like DBeaver or Spring Boot).

| Service | Container Name | Internal Port | Host Port | Credentials / Config | Description |
| --- | --- | --- | --- | --- | --- |
| **MariaDB** | `network_mariadb` | `3306` | **3306** | **User:** `user`<br><br>**Pass:** `password`<br><br>**DB:** `network_traffic_db`<br><br>**Root Pass:** `rootpassword` | Main storage for logs and AI analysis. |
| **Kafka** | `network_kafka` | `9092` | **9092** | *No Auth (Plaintext)* | Message Broker. Exposed on 9092 for Host access (Tshark). |
| **Zookeeper** | `network_zookeeper` | `2181` | - | - | Orchestrator for Kafka cluster state. |
| **Spark Master** | `spark_master` | `7077`, `8080` | **8080** | **UI:** http://localhost:8080 | Spark Cluster Manager. |
| **Spark Worker** | `spark_worker` | Random | - | **Mem Limit:** 1GB | Execution node for streaming jobs. |
| **Kafka UI** | `kafka_ui` | `8080` | **8090** | **UI:** http://localhost:8090 | Web interface to monitor Kafka Topics. |

---

## ⌨️ Docker Command Reference

While the scripts handle the setup, these commands are useful for day-to-day management and debugging.

### Lifecycle Management

* **Stop services:**
`docker compose stop`
*(Pauses containers. Data is preserved.)*
* **Stop and Remove containers:**
`docker compose down`
*(Removes containers and networks. Data in volumes is preserved.)*
* **🔥 HARD RESET (Delete Data):**
`docker compose down -v`
*(Removes containers, networks, AND database volumes. Database will be empty on next start.)*

### Debugging & Logs

* **View logs for a specific service:**
`docker compose logs -f [service_name]`
*(Example: `docker compose logs -f spark-master`)*
* **Check container status:**
`docker compose ps`
* **Access a running container's shell:**
`docker exec -it [container_name] /bin/bash`

---

## 🗄️ Database Layer (MariaDB)

### Why MariaDB?

We selected MariaDB for this pipeline because:

1. **Relational Structure:** Network logs (IPs, Ports, Protocols) are highly structured, making SQL efficient for querying specific timeframes or subnets.
2. **ACID Compliance:** Ensures that no packet log is lost during the write process from Spark.
3. **Compatibility:** Fully compatible with MySQL drivers used by Spring Boot.

### Schema Design

The database uses a normalized schema to separate raw high-volume logs from detailed AI insights.

1. **`traffic_logs`**: Contains the raw metadata (Source IP, Dest IP, Protocol, Length).
2. **`ai_threat_logs`**: Linked via Foreign Key. Contains the AI's explanation and Risk Score (High/Medium/Low).

### Useful MariaDB Commands

You can execute these directly via the `docker exec` command or a SQL client.

* **Enter Database Shell:**
```bash
docker exec -it network_mariadb mariadb -u user -ppassword

```


* **Select Database:**
```sql
USE network_traffic_db;

```


* **View All Logs:**
```sql
SELECT * FROM traffic_logs ORDER BY event_time DESC LIMIT 10;

```


* **View Threats Only (Join Query):**
```sql
SELECT t.source_ip, t.protocol, a.severity_level, a.ai_explanation
FROM traffic_logs t
JOIN ai_threat_logs a ON t.id = a.log_id
WHERE a.severity_level = 'HIGH';

```



---

## 📡 Data Ingestion Layer (Wireshark to Kafka)

This phase establishes the "pipe" that captures live network traffic and streams it into the Big Data infrastructure.

### 🔄 The Ingestion Pipeline
The system uses a **Producer-Consumer** pattern to decouple packet capture from processing.

`[Network Interface (ens33)]` ➔ `[Tshark Capture]` ➔ `[Pipe |]` ➔ `[Python Producer]` ➔ `[Kafka Topic: network-traffic]`

1.  **Capture:** `Tshark` listens to the active network interface.
2.  **Format:** Converts raw binary packets into **JSON** format.
3.  **Stream:** Pipes the JSON output directly to a Python script (`stdin`).
4.  **Push:** The Python script cleans the data and pushes it to the Kafka Broker on port **9092**.

---

### 🛠️ Setup & Execution

Two scripts manage the ingestion layer. Run them in the following order:

#### Step 1: Install Dependencies (`04-install-tools.sh`)
Installs Wireshark/Tshark, Python 3, and the `kafka-python-ng` library.
* **Key Action:** Configures user permissions to allow packet capture without `sudo` (root) privileges.
* **Command:**
    ```bash
    ./04-install-tools.sh
    ```
    *> Note: You may need to log out and log back in (or run `newgrp wireshark`) for permissions to take effect.*

#### Step 2: Start Traffic Capture (`05-start-capture.sh`)
Automatically detects your primary network interface and starts the streaming pipeline.
* **Command:**
    ```bash
    ./05-start-capture.sh
    ```
* **Verification:** You should see dots (`.......`) printing on the terminal. Each dot represents a captured packet sent to Kafka.

---

### 🧠 Technical Deep Dive

| Component | Technical Detail | Explanation |
| :--- | :--- | :--- |
| **Interface `ens33`** | **Predictable Network Interface Names** | On modern Linux systems (Ubuntu 24.04), network interfaces are named based on firmware/BIOS location. `ens33` is the standard identifier for the primary Ethernet adapter in VMware/Virtual environments (replacing the old `eth0`). |
| **Port 9092** | **PLAINTEXT_HOST** | The Kafka Broker exposes port **9092** specifically for external producers (like our Python script running on the Host OS). Internal Docker containers communicate on port `29092`. |
| **Data Format** | **JSON Serialization** | Tshark is configured with `-T json`. We chose JSON over PCAP because it is human-readable and easily parsed by Spark and Python without complex binary decoding libraries. |
| **Buffering** | **Line Buffered (`-l`)** | The `tshark -l` flag is critical. It forces Tshark to flush data to the pipe immediately after each packet, ensuring **Real-Time** streaming instead of waiting for a buffer to fill up. |

---

### 🔧 Troubleshooting & Fixes Implemented

During the development of the Ingestion Layer, the following architectural fixes were applied:

#### 1. Kafka Version Compatibility (KRaft vs Zookeeper)
* **Issue:** The `latest` Kafka image defaulted to KRaft mode, causing `NoBrokersAvailable` errors due to missing role configuration.
* **Fix:** Pinned the Kafka and Zookeeper image versions to **`7.4.0`**. This ensures a stable, Zookeeper-based cluster compatible with standard `cp-kafka` configurations.

#### 2. Tshark Permission Denied
* **Issue:** `tshark: Couldn't run dumpcap in child process: Permission denied`.
* **Fix:** Added the user to the `wireshark` group via `usermod -aG wireshark $USER` and reconfigured `dpkg-reconfigure wireshark-common` to allow non-superusers to capture packets.

#### 3. IPv6/IPv4 Binding
* **Issue:** The Python script failed to connect to `localhost:9092` on Ubuntu systems where `localhost` resolves to `::1` (IPv6).
* **Fix:** Hardcoded the Producer bootstrap server to **`127.0.0.1:9092`** to force IPv4 connectivity with the Docker container.