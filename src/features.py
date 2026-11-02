import os
import joblib
import pandas as pd
from sklearn.preprocessing import StandardScaler

def prepare_features(df: pd.DataFrame):
    """
    Menyiapkan dan menyesuaikan variabel input dari dataset obesity/diet.
    Variabel input: umur, tinggi (cm), berat (kg), frekuensi_olahraga (0-3).
    """
    # Bersihkan spasi pada nama kolom
    df.columns = [c.strip() for c in df.columns]
    
    # Mapping nama kolom standar UCI ObesityDataSet jika ada
    column_mapping = {
        'Age': 'umur',
        'Height': 'tinggi',
        'Weight': 'berat',
        'FAF': 'frekuensi_olahraga',
        'NObeyesdad': 'kategori_diet'
    }
    df_mapped = df.rename(columns=column_mapping)
    
    # Konversi tinggi ke centimeter jika dalam bentuk meter (misal: 1.70 m -> 170 cm)
    if 'tinggi' in df_mapped.columns and df_mapped['tinggi'].max() < 3.0:
        df_mapped['tinggi'] = df_mapped['tinggi'] * 100.0

    # Bulatkan frekuensi olahraga ke skala 0-3
    if 'frekuensi_olahraga' in df_mapped.columns:
        df_mapped['frekuensi_olahraga'] = df_mapped['frekuensi_olahraga'].round().astype(int).clip(0, 3)

    feature_cols = ['umur', 'tinggi', 'berat', 'frekuensi_olahraga']
    
    # Cari nama kolom target
    target_col = None
    for col in ['kategori_diet', 'NObeyesdad', 'Obesity', 'Class']:
        if col in df_mapped.columns:
            target_col = col
            break
            
    if target_col is None:
        target_col = df_mapped.columns[-1]

    X = df_mapped[feature_cols]
    y = df_mapped[target_col]
    
    return X, y


def fit_save_scaler(X_train: pd.DataFrame, scaler_path: str = "models/scaler.pkl"):
    """
    Melakukan fit StandardScaler pada data training, menyimpan objek scaler ke folder models/,
    dan mengembalikan data training yang ter-scaling.
    """
    os.makedirs(os.path.dirname(scaler_path), exist_ok=True)
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    
    joblib.dump(scaler, scaler_path)
    print(f"[✓] Scaler berhasil disimpan di: {scaler_path}")
    
    return X_train_scaled, scaler