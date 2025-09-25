# 🌐 BLE IoT Environmental Monitoring System

The main goal of this system is to implement an **IoT-based environmental monitoring solution**.  
The system operates in **two interconnected phases**:

---

## 🔹 1. Data Acquisition (Slave)
The **Slave device** is responsible for:
- Measuring key environmental parameters: **Temperature, Pressure, and Humidity**  
- Transmitting these measurements in real time to the **Master device** via the **Bluetooth Low Energy (BLE)** protocol  

---

## 🔹 2. Data Processing & Forwarding (Master/Gateway)
The **Master device** acts as a **Gateway**, performing the following tasks:
- Receiving sensor data from the Slave  
- Executing local statistical processing (**Edge Computing**) to compute:  
  - **Mean**  
  - **Standard Deviation**  
- Forwarding the aggregated results to a **remote server/sink** using **WiFi connectivity**  

---

📡 This architecture combines **BLE energy efficiency** for local data collection with **WiFi-based connectivity** for reliable remote monitoring.
