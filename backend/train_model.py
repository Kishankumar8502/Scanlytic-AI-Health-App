import pandas as pd
import numpy as np
import pickle
import os
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from model_utils import federated_average

def train():
    try:
        print("Training started...")
        # Load CSV using pandas
        csv_path = os.path.join(os.path.dirname(__file__), "heart.csv")
        df = pd.read_csv(csv_path)
        
        if 'target' not in df.columns:
            print("Error: 'target' column not found in dataset.")
            return False
            
        X = df.drop("target", axis=1)
        y = df["target"]
        
        # Simulate 3 clients by splitting data evenly
        chunk_size = len(df) // 3
        
        client_data = [
            (X.iloc[0:chunk_size], y.iloc[0:chunk_size]),
            (X.iloc[chunk_size:2*chunk_size], y.iloc[chunk_size:2*chunk_size]),
            (X.iloc[2*chunk_size:], y.iloc[2*chunk_size:])
        ]
        
        client_weights = []
        
        print("--- Client Training ---")
        for idx, (X_client, y_client) in enumerate(client_data):
            print(f"Training Client {idx + 1} on {len(X_client)} samples...")
            
            # Train StandardScaler + LogisticRegression pipeline
            pipeline = Pipeline([
                ('scaler', StandardScaler()),
                ('log_reg', LogisticRegression(max_iter=1000))
            ])
            
            pipeline.fit(X_client, y_client)
            
            # Extract model coefficients from each client
            model = pipeline.named_steps['log_reg']
            client_weights.append({
                'coef_': model.coef_,
                'intercept_': model.intercept_,
                'classes_': model.classes_
            })
            
        # Send them to model_utils.py for aggregation
        aggregated = federated_average(client_weights, privacy_noise=True, noise_scale=0.01)
        
        # Create a global LogisticRegression model using aggregated weights
        global_pipeline = Pipeline([
            ('scaler', StandardScaler()),
            ('log_reg', LogisticRegression())
        ])
        
        # We need a unified Scaler. Fitting it globally on the entire dataset
        # to ensure unified normalization dimensions, which is standard in a simulated simple aggregation setup.
        global_pipeline.named_steps['scaler'].fit(X)
        
        # Dummy fit to configure model dimensions implicitly before setting manual weights
        # Ensure we have one sample of each unique class to avoid solver errors
        unique_classes = y.unique()
        sample_indices = [y[y == cls].index[0] for cls in unique_classes]
        global_pipeline.named_steps['log_reg'].fit(X.loc[sample_indices], y.loc[sample_indices])
        
        # Use aggregated weights for the global model
        global_pipeline.named_steps['log_reg'].coef_ = aggregated['coef_']
        global_pipeline.named_steps['log_reg'].intercept_ = aggregated['intercept_']
        global_pipeline.named_steps['log_reg'].classes_ = client_weights[0]['classes_']
        
        # Save model as model.pkl using pickle
        model_path = os.path.join(os.path.dirname(__file__), "model.pkl")
        with open(model_path, "wb") as f:
            pickle.dump(global_pipeline, f)
            
        print("Model saved successfully as model.pkl")
        return True
        
    except FileNotFoundError:
        print("Error: heart.csv not found.")
        return False
    except Exception as e:
        print(f"An error occurred during training: {e}")
        return False

if __name__ == "__main__":
    train()
