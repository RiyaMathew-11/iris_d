import joblib
import numpy as np
import sys
import json

def predict(input_data):
    model = joblib.load("priv/python/models/best_iris_model.pkl")
    data = np.array([list(map(float, input_data))])
    prediction = model.predict(data)
    return prediction[0]

if __name__ == "__main__":
    input_data = json.loads(sys.argv[1])
    result = predict(input_data)
    print(json.dumps(str(result)))

