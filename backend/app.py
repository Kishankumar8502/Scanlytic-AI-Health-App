from flask import Flask, request, jsonify
import pickle
import os
import numpy as np
from datetime import datetime

app = Flask(__name__)

@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, DELETE, OPTIONS'
    return response

# Try to load model on startup
MODEL_PATH = os.path.join(os.path.dirname(__file__), "model.pkl")
global_model = None

# Global state to store incoming patient predictions for the doctor dashboard
stored_patients = [
    {"patient_id": "PT-7829", "patient_name": "Robert Smith", "risk": 88.5, "status": "High Risk", "timestamp": "2026-04-08 14:00:00"},
    {"patient_id": "PT-3491", "patient_name": "Jane Austen", "risk": 22.0, "status": "Low Risk", "timestamp": "2026-04-08 13:45:00"},
    {"patient_id": "PT-1102", "patient_name": "Tom Hanks", "risk": 75.3, "status": "High Risk", "timestamp": "2026-04-08 12:30:00"},
]

def load_or_train_model():
    global global_model
    if not os.path.exists(MODEL_PATH):
        print("model.pkl not found. Initiating auto-training...")
        try:
            from train_model import train
            success = train()
            if not success:
                print("Auto-training failed.")
                return False
        except ImportError:
            print("train_model.py not found for auto-training.")
            return False
            
    try:
        with open(MODEL_PATH, "rb") as f:
            global_model = pickle.load(f)
        print("Model loaded successfully.")
        return True
    except Exception as e:
        print(f"Failed to load model: {e}")
        return False

# Initialize model
load_or_train_model()

@app.route("/")
def home():
    return "API Running"

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "model_loaded": global_model is not None,
    })

@app.route("/predict", methods=["POST"])
def predict():
    # Model check
    if global_model is None:
        return jsonify({"error": "Model is not loaded or trained yet"}), 500

    # JSON check
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400
        
    data = request.get_json()
    
    # Check 'features' key
    if data is None or 'features' not in data:
        return jsonify({"error": "Missing 'features' key in request JSON"}), 400
        
    features = data.get('features')
    patient_id = data.get('patient_id', 'Unknown')
    patient_name = data.get('patient_name', 'Unknown')
    
    # Check if features is a list
    if not isinstance(features, list):
        return jsonify({"error": "'features' must be an array"}), 400
        
    # Length check (must be exactly 13 features)
    if len(features) != 13:
        return jsonify({"error": f"Expected exactly 13 features, got {len(features)}"}), 400
        
    # Numeric check
    try:
        # Convert all features to float
        float_features = [float(x) for x in features]
    except (ValueError, TypeError):
        return jsonify({"error": "All feature values must be numeric"}), 400
        
    # Make prediction
    try:
        # Reshape to 2D array as required by sklearn pipeline
        features_array = np.array(float_features).reshape(1, -1)
        
        prediction = global_model.predict(features_array)[0]
        
        # Get probability for the predicted class
        probabilities = global_model.predict_proba(features_array)[0]
        
        # Usually binary classification (0 or 1), 1 indicates risk
        if len(probabilities) > 1:
            risk_prob = probabilities[1]
        else:
            risk_prob = 1.0 if prediction == 1 else 0.0
            
        risk_percentage = risk_prob * 100
        status_text = "High Risk" if prediction == 1 else "Low Risk"
        
        advice_text = (
            "Your diagnostic pattern exhibits elevated cardiovascular markers. We strongly recommend immediate clinical assessment."
            if prediction == 1 else 
            "Your profile appears stable and within standard thresholds. Continue preventative habits."
        )
        
        # Store in backend memory for the doctor dashboard
        if patient_id != 'Unknown':
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            stored_patients.insert(0, {
                "patient_id": patient_id,
                "patient_name": patient_name if patient_name != 'Unknown' else 'Unregistered',
                "risk": round(risk_percentage, 2),
                "status": status_text,
                "timestamp": timestamp
            })
        
        return jsonify({
            "prediction": int(prediction),
            "risk": round(risk_percentage, 2),
            "status": status_text,
            "advice": advice_text,
            "alert": int(prediction) == 1
        })
        
    except Exception as e:
        return jsonify({"error": f"Prediction computation failed: {str(e)}"}), 500

@app.route("/predict", methods=["OPTIONS"])
@app.route("/doctor/dashboard", methods=["OPTIONS"])
@app.route("/doctor/dashboard/all", methods=["OPTIONS"])
@app.route("/doctor/dashboard/<patient_id>", methods=["OPTIONS"])
def options_handler(patient_id=None):
    return ('', 204)

@app.route("/doctor/dashboard", methods=["GET"])
def doctor_dashboard():
    return jsonify({"patients": stored_patients})

@app.route("/doctor/dashboard/all", methods=["DELETE"])
def delete_all_patients():
    stored_patients.clear()
    return jsonify({"message": "All patient data deleted"})

@app.route("/doctor/dashboard/<patient_id>", methods=["DELETE"])
def delete_patient(patient_id):
    global stored_patients
    original_len = len(stored_patients)
    stored_patients = [p for p in stored_patients if p.get('patient_id') != patient_id]
    if len(stored_patients) < original_len:
        return jsonify({"message": f"Patient {patient_id} deleted"})
    return jsonify({"error": "Patient not found"}), 404

if __name__ == "__main__":
    # Environment-driven startup keeps local/dev/phone testing predictable.
    host = os.getenv("FLASK_HOST", "0.0.0.0")
    port = int(os.getenv("FLASK_PORT", "5000"))
    debug = os.getenv("FLASK_DEBUG", "0") == "1"
    use_reloader = os.getenv("FLASK_RELOADER", "0") == "1"
    app.run(debug=debug, host=host, port=port, use_reloader=use_reloader)
