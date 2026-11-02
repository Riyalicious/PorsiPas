import pandas as pd
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.neural_network import MLPClassifier
import joblib

print("Membaca dataset...")
df = pd.read_csv("data/dataset_diet.csv") 

# Memilih fitur X (input) dan target y (output)
X = df[['Age', 'Height_cm', 'Weight_kg', 'Exercise_Frequency']]
y = df['Recommended_Meal_Plan']  # Menggunakan kolom target yang benar

print("Memproses data...")
le = LabelEncoder()
y_encoded = le.fit_transform(y)

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

print("Melatih model MLP (Multi-Layer Perceptron)...")
mlp = MLPClassifier(hidden_layer_sizes=(64, 32), max_iter=500, random_state=42)
mlp.fit(X_scaled, y_encoded)

print("Menyimpan model ke folder models/...")
joblib.dump(mlp, "models/mlp_model.pkl")
joblib.dump(scaler, "models/scaler.pkl")
joblib.dump(le, "models/label_encoder.pkl")

print("✅ Selesai! Model lokal berhasil dibuat di folder models/")