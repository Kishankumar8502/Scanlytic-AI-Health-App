# 🧠 Scanlytic AI Health App

A privacy-focused AI healthcare system that predicts disease risk using **Machine Learning** and simulated **Federated Learning principles**.

---

## 🌐 Live Backend API

👉 https://scanlytic-ai-health-app.onrender.com

⚠️ Note: Free Render server may sleep after inactivity (first request may take 30–50 seconds)

---

## 🚀 Features

* 📊 Heart Disease Risk Prediction
* 🤖 Machine Learning Model (Logistic Regression)
* 🔄 Federated Learning Simulation (Multi-client training)
* 🔐 Differential Privacy (simulated noise addition)
* 📱 Flutter Mobile App
* 🚨 Real-time Risk Alerts
* 👨‍⚕️ Doctor Dashboard

---

## 🧠 How It Works

1. User enters health data in Flutter app
2. Data is sent to Flask backend API
3. ML model predicts disease risk
4. Risk percentage is returned
5. High-risk patients are flagged

---

## 🔄 Federated Learning (Simulation)

* Dataset split into multiple clients
* Each client trains locally
* Only model parameters shared
* Aggregation via Federated Averaging
* Noise added for privacy simulation

---

## 🧱 Tech Stack

* **Frontend:** Flutter
* **Backend:** Flask (Python)
* **ML:** Scikit-learn
* **Concepts:** Federated Learning, Differential Privacy

---

## 📂 Project Structure

backend/ → Flask API (deployed on Render)
scanlytics/ → Flutter mobile app

---

## ⚙️ Run Locally (Optional)

### 🔹 Backend

```bash
cd backend
pip install -r requirements.txt
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

## 📱 API Configuration (IMPORTANT)

Update API URL in Flutter:

```dart
const String baseUrl = "https://scanlytic-ai-health-app.onrender.com";
```

---

## ⚠️ Notes

* This is a **prototype system**
* Federated Learning is **simulated**
* Dataset is from **public sources (Kaggle)**

---

## 🚀 Future Improvements

* Firebase Authentication
* Real-time wearable integration
* Secure aggregation
* Model improvement (Random Forest / XGBoost)
* Full production deployment

---

## 👨‍💻 Author

Kishan Kumar

---

## ⭐ Support

If you like this project, give it a ⭐ on GitHub!
