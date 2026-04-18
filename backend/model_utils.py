import numpy as np

def federated_average(clients_weights, privacy_noise=True, noise_scale=0.01):
    """
    Simulates federated averaging by aggregating client weights.
    clients_weights: list of dicts, each containing 'coef_' and 'intercept_'
    privacy_noise: boolean, whether to add small random noise to coefficients for privacy simulation
    noise_scale: scale of the random normal noise to add for privacy
    """
    if not clients_weights:
        return None

    print("--- Aggregation Step ---")
    
    n_clients = len(clients_weights)
    
    # Extract coefficients and intercepts
    coefs = []
    intercepts = []
    
    for idx, weights in enumerate(clients_weights):
        c = weights['coef_'].copy()
        i = weights['intercept_'].copy()
        
        # Add noise if requested
        if privacy_noise:
            c += np.random.normal(loc=0.0, scale=noise_scale, size=c.shape)
            i += np.random.normal(loc=0.0, scale=noise_scale, size=i.shape)
            print(f"Added privacy noise to Client {idx + 1} weights.")
            
        coefs.append(c)
        intercepts.append(i)
        
    # Average the weights across all clients
    avg_coef = np.mean(coefs, axis=0)
    avg_intercept = np.mean(intercepts, axis=0)
    
    print(f"Federated averaging complete. Aggregated {n_clients} models.")
    
    return {
        'coef_': avg_coef,
        'intercept_': avg_intercept
    }
