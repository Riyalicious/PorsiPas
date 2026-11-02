import os
import sys
import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import classification_report, accuracy_score

# Memastikan direktori src dapat di-import dengan benar
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from features import prepare_features, fit_save_scaler

def train_mlp_model():
    data_path = "data/raw/diet_data.csv"
    model_output_path = "models/mlp_model.pkl"
    scaler_output_path = "models/scaler.pkl"
    
    print("==================================================")
    print("Mulai Proses Pelatihan Model Multi-Layer Perceptron")
    print("==================================================")

    # 1. Load Dataset
    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Dataset tidak ditemukan di {data_path}. Pastikan file diet_data.csv sudah ada.")
        
    print(f"[+] Membaca dataset dari {data_path}...")
    df = pd.read_csv(data_path)

    # 2. Preprocessing & Feature Extraction
    X, y = prepare_features(df)
    print(f"[+] Jumlah sampel data: {len(X)} baris.")

    # 3. Train-Test Split (80% Train, 20% Test)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    # 4. Feature Scaling & Simpan Scaler Artifact
    X_train_scaled, scaler = fit_save_scaler(X_train, scaler_output_path)
    X_test_scaled = scaler.transform(X_test)

    # 5. Inisialisasi & Training Model MLPClassifier
    print("[+] Melatih MLPClassifier...")
    mlp = MLPClassifier(
        hidden_layer_sizes=(128, 64, 32),
        activation='relu',
        solver='adam',
        max_iter=500,
        random_state=42
    )
    mlp.fit(X_train_scaled, y_train)

    # 6. Evaluasi Model
    y_pred = mlp.predict(X_test_scaled)
    acc = accuracy_score(y_test, y_pred)
    print("\n--------------------------------------------------")
    print(f"[✓] AKURASI MODEL MLP: {acc * 100:.2f}%")
    print("--------------------------------------------------")
    print("\nLaporan Evaluasi Per Kategori Diet:")
    print(classification_report(y_test, y_pred))

    # 7. Simpan Model Artifact (.pkl)
    os.makedirs(os.path.dirname(model_output_path), exist_ok=True)
    joblib.dump(mlp, model_output_path)
    print(f"[✓] Model MLP berhasil disimpan di: {model_output_path}")
    print("==================================================\n")

if __name__ == "__main__":
    train_mlp_model()