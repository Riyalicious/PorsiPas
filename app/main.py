from fastapi import FastAPI, HTTPException
import pandas as pd
import joblib
import numpy as np
from app.schemas import UserData

app = FastAPI(
    title="PorsiPas AI Backend",
    version="1.0.0",
    description="Backend API untuk rekomendasi porsi diet berbasis MLP"
)

# Load Artefak & Database saat startup
try:
    mlp_model = joblib.load("models/mlp_model.pkl")
    scaler = joblib.load("models/scaler.pkl")
    label_encoder = joblib.load("models/label_encoder.pkl")
    df_menu = pd.read_csv("data/database_menu_gabungan.csv").fillna({
        'Kalori': 0, 'Protein': 0, 'Lemak': 0, 'Karbohidrat': 0,
        'Gambar': 'https://via.placeholder.com/150'
    })
    print("✅ Resource AI & Database menu berhasil dimuat!")
except Exception as e:
    print(f"❌ Error loading resources: {e}")

@app.get("/")
def root():
    return {"status": "online", "app": "PorsiPas AI Backend"}

@app.post("/api/v1/predict")
def predict_diet(user: UserData):
    try:
        # 1. Prediksi AI (MLP)
        input_features = np.array([[user.umur, user.tinggi, user.berat, user.frekuensi_olahraga]])
        input_scaled = scaler.transform(input_features)
        pred_idx = mlp_model.predict(input_scaled)
        diet_type = label_encoder.inverse_transform(pred_idx)[0]

        # 2. Perhitungan Metabolisme & Kalori
        bmr = (10 * user.berat) + (6.25 * user.tinggi) - (5 * user.umur) + (5 if user.is_pria else -161)
        tdee = bmr * (1.2 + (user.frekuensi_olahraga * 0.1))

        if user.target_tubuh == "Menurunkan Berat Badan":
            target_kalori = tdee - 500
        elif user.target_tubuh == "Menaikkan Berat Badan":
            target_kalori = tdee + 400
        else:
            target_kalori = tdee

        # 3. Pengambilan Menu dari Database
        sarapan = df_menu[(df_menu['Kalori'] >= (target_kalori * 0.20)) & (df_menu['Kalori'] <= (target_kalori * 0.30))].sample(1).iloc[0]
        siang = df_menu[(df_menu['Kalori'] >= (target_kalori * 0.35)) & (df_menu['Kalori'] <= (target_kalori * 0.45))].sample(1).iloc[0]
        malam = df_menu[(df_menu['Kalori'] >= (target_kalori * 0.30)) & (df_menu['Kalori'] <= (target_kalori * 0.40))].sample(1).iloc[0]

        return {
            "status_kesehatan": f"{diet_type} (AI)",
            "target_kalori_harian": round(target_kalori, 2),
            "kebutuhan_air_ml": round(user.berat * 35, 2),
            "kebutuhan_air_gelas": int((user.berat * 35) / 250),
            "skor_kesehatan": 85,
            "porsi_makan": {
                "sarapan": {
                    "target_kalori": round(target_kalori * 0.25, 2),
                    "menu": {
                        "nama": sarapan['Nama_Menu'],
                        "kategori": "Sarapan",
                        "image_url": sarapan['Gambar'],
                        "karbohidrat": float(sarapan['Karbohidrat']),
                        "protein": float(sarapan['Protein']),
                        "lemak": float(sarapan['Lemak'])
                    }
                },
                "makan_siang": {
                    "target_kalori": round(target_kalori * 0.40, 2),
                    "menu": {
                        "nama": siang['Nama_Menu'],
                        "kategori": "Makan Siang",
                        "image_url": siang['Gambar'],
                        "karbohidrat": float(siang['Karbohidrat']),
                        "protein": float(siang['Protein']),
                        "lemak": float(siang['Lemak'])
                    }
                },
                "makan_malam": {
                    "target_kalori": round(target_kalori * 0.35, 2),
                    "menu": {
                        "nama": malam['Nama_Menu'],
                        "kategori": "Makan Malam",
                        "image_url": malam['Gambar'],
                        "karbohidrat": float(malam['Karbohidrat']),
                        "protein": float(malam['Protein']),
                        "lemak": float(malam['Lemak'])
                    }
                }
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))