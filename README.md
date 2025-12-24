# 🛡️ AI-Powered Network Traffic Analyzer

An end-to-end data engineering pipeline for real-time network traffic analysis, anomaly detection, and AI-driven threat explanation.

## 🏗️ System Architecture
The system follows a **Microservices Event-Driven Architecture**, fully containerized using Docker.
![System Architecture Diagram](/images/architecture_diagram.jpg)

## 📂 Repository Structure

### 1. [Packet Analysis with Kafka and Wireshark](./Packet%20Analysis%20with%20Kafka%20and%20Wireshark)
**Phase 1 & 2:** Infrastructure Setup & Ingestion Layer.
* Captures real-time packets using **Wireshark/Tshark**.
* Streams data to **Apache Kafka**.
* Contains all infrastructure setup scripts (`.sh`) and the Python Producer.

### 2. [Data Analysis with Spark and Kafka](./Data%20Analysis%20with%20Spark%20and%20Kafka)
**Phase 3:** Processing & Analytics Layer.
* Consumes data from Kafka using **Apache Spark**.
* Performs stream processing and anomaly detection.
* Stores results in **MariaDB**.

---

