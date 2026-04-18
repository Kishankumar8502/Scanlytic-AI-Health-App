# 🧠 Scanlytic AI Health App

A privacy-focused AI healthcare system that predicts disease risk using **Federated Learning principles** and **Machine Learning**.

---

## 🚀 Features

* 📊 Disease Risk Prediction (Heart Disease)
* 🤖 Machine Learning Model (Logistic Regression)
* 🔄 Federated Learning Simulation (Multi-client training)
* 🔐 Privacy-Preserving AI (Differential Privacy simulation)
* 📱 Flutter Mobile App UI
* 🚨 Real-time Risk Alerts
* 👨‍⚕️ Doctor Dashboard (Patient monitoring)

---

## 🧠 How It Works

1. User enters health data in the mobile app
2. Data is sent to Flask backend API
3. Model predicts disease risk using trained ML model
4. Risk percentage is returned and displayed
5. High-risk patients are highlighted for doctors

---

## 🔄 Federated Learning (Simulation)

* Dataset is divided into multiple clients
* Each client trains its own local model
* Only model parameters (not raw data) are shared
* Aggregation is done using Federated Averaging
* Privacy noise is added to simulate Differential Privacy

---

## 🧱 Tech Stack

* **Frontend:** Flutter
* **Backend:** Python Flask
* **ML:** Scikit-learn
* **Concepts:** Federated Learning, Differential Privacy

---

## ⚙️ Setup Instructions

### 🔹 Backend

```bash
cd backend
pip install -r requirements.txt
python train_model.py
python app.py
```

---

### 🔹 Frontend

```bash
cd scanlytics
flutter pub get
flutter run
```

---

## 🌐 API Configuration

⚠️ Update API base URL in Flutter before running:

```dart
const String baseUrl = "http://YOUR_IP:5000";
```

---

## ⚠️ Note

* This is a **prototype system**
* Federated Learning is **simulated**
* Dataset is from **public sources (Kaggle)**

---

## 🚀 Future Improvements

* Firebase Authentication (User & Doctor roles)
* Real-time wearable data integration
* Secure encrypted aggregation
* Cloud deployment (Render / AWS)

---

## 👨‍💻 Author

Kishan Kumar

---


## ▶️ Running the App (Full Setup)

### 🔹 Step 1: Start Backend Server

```bash
cd backend
python app.py
```

Make sure Flask is running on:

```
http://0.0.0.0:5000
```

---

### 🔹 Step 2: Find Your Local IP

Run:

```bash
ipconfig
```

Copy your IPv4 address (example):

```
192.168.X.X
```

---

### 🔹 Step 3: Update API URL in Flutter

Go to:

```
lib/services/api_service.dart
```

Update:

```dart
const String baseUrl = "http://192.168.X.X:5000";
```

---

### 🔹 Step 4: Connect Device

* Ensure **mobile phone and laptop are on same WiFi**
* Enable USB debugging OR use wireless debugging

---

### 🔹 Step 5: Run Flutter App

```bash
cd scanlytics
flutter run
```

---

### 🔹 Step 6: Test the App

* Enter patient data
* Click **Analyze Risk**
* View real-time prediction results

---

## ⚠️ Troubleshooting

* ❌ Connection timeout → Check IP & WiFi
* ❌ API not working → Ensure Flask is running
* ❌ Wrong results → Verify input format

---
## ⭐ If you like this project

Give it a ⭐ on GitHub!