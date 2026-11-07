from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import joblib
import numpy as np
from app.schemas import UserData, DietRecommendationResponse
import os

app = FastAPI(
    title="PorsiPas AI Backend",
    version="3.0.3"
)

class RegenerateRequest(BaseModel):
    kategori: str

file_path = "data/menu_combined.csv"
if not os.path.exists(file_path):
    print(f"⚠️ PERINGATAN: File {file_path} tidak ditemukan!")

try:
    mlp_model = joblib.load("models/mlp_model.pkl")
    scaler = joblib.load("models/scaler.pkl")
    label_encoders = joblib.load("models/label_encoders.pkl")
    
    df_menu = pd.read_csv(file_path)
    df_menu = df_menu.fillna({
        'Kalori': 0, 'Protein': 0, 'Lemak': 0, 'Karbohidrat': 0,
        'Gambar': 'https://via.placeholder.com/150'
    })
    print(f"✅ Database Menu Gabungan siap! Total Menu: {len(df_menu)}")
except Exception as e:
    print(f"❌ Error kritis saat memuat artefak/CSV: {e}")
    df_menu = pd.DataFrame()

gym_to_category = {
    'Balanced diet with moderate protein and carbohydrates: Chicken breast, brown rice, spinach, eggs, apple': 'Balanced',
    'High-calorie, protein-rich diet: Whole milk, peanut butter, eggs, salmon, sweet potatoes': 'High-Protein',
    'Low-calorie, nutrient-dense diet with portion control: carrot sticks,grilled chicken breast,steamed broccoli, Greek yogurt, mixed nuts, baked salmon, leafy greens, roasted sweet potatoes': 'Low-Fat',
    'Low-carb, high-fiber diet: Avocado, grilled fish, broccoli, almonds, leafy greens': 'Low-Carb'
}

exercise_map = {
    0: 'Light weightlifting, Yoga, and 2000 steps walking',
    1: 'Moderate cardio, Strength training, and 5000 steps walking',
    2: 'High-intensity interval training (HIIT), Cardio, and 8000 steps walking',
    3: 'Low-impact cardio, Swimming, and 10000 steps walking'
}

def hitung_porsi(target_kal, kalori_db):
    try:
        kal = float(kalori_db)
        if kal <= 0: return 100
        return int(round((target_kal / kal) * 100))
    except:
        return 100

def get_sample_menu(df, category, min_cal, max_cal):
    if df is None or df.empty: return None
    
    # Filter berdasarkan kategori AI
    subset = df[df['Diet_Category'] == category]
    if subset.empty: subset = df
    
    # Filter kalori
    filtered = subset[(subset['Kalori'] >= min_cal) & (subset['Kalori'] <= max_cal)]
    if filtered.empty:
        filtered = subset
    return filtered.sample(n=1).iloc[0]

def _format_menu(row, target_kal, kategori):
    if row is None or len(row) == 0: 
        return {
            "nama": "Menu Sedang Diproses", 
            "kategori": kategori, 
            "image_url": "https://via.placeholder.com/150", 
            "karbohidrat": 0.0, 
            "protein": 0.0, 
            "lemak": 0.0,
            "porsi_gram": 100
        }
    
    return {
        "nama": str(row.get('Nama_Menu', 'Menu Default')), 
        "kategori": kategori, 
        "image_url": str(row.get('Gambar', 'https://via.placeholder.com/150')), 
        "karbohidrat": float(row.get('Karbohidrat', 0)), 
        "protein": float(row.get('Protein', 0)), 
        "lemak": float(row.get('Lemak', 0)),
        "porsi_gram": hitung_porsi(target_kal, row.get('Kalori', 0))
    }

@app.post("/api/v1/predict")
def predict_diet(user: UserData):
    # 1. Map input user ke kategori GYM.csv
    gender_str = 'Male' if user.is_pria else 'Female'
    
    if user.target_tubuh == "Menurunkan Berat Badan":
        goal_str = 'fat_burn'
    elif user.target_tubuh == "Menaikkan Berat Badan":
        goal_str = 'muscle_gain'
    else:
        goal_str = 'fat_burn'
        
    bmi = user.berat / ((user.tinggi / 100) ** 2)
    if bmi < 18.5: bmi_str = 'Underweight'
    elif 18.5 <= bmi < 25.0: bmi_str = 'Normal weight'
    elif 25.0 <= bmi < 30.0: bmi_str = 'Overweight'
    else: bmi_str = 'Obesity'
    
    exercise_str = exercise_map.get(user.frekuensi_olahraga, 'Moderate cardio, Strength training, and 5000 steps walking')

    # 2. Encoding & Scaling untuk MLP
    input_encoded = pd.DataFrame([{
        'Gender': label_encoders['Gender'].transform([gender_str])[0],
        'Goal': label_encoders['Goal'].transform([goal_str])[0],
        'BMI Category': label_encoders['BMI Category'].transform([bmi_str])[0],
        'Exercise Schedule': label_encoders['Exercise Schedule'].transform([exercise_str])[0]
    }])
    
    input_scaled = scaler.transform(input_encoded)
    pred_idx = mlp_model.predict(input_scaled)[0]
    raw_label = label_encoders['Meal Plan'].inverse_transform([pred_idx])[0]
    diet_category = gym_to_category[raw_label]

    # 3. Hitung BMR, TDEE, & Kalori Target
    bmr = (10 * user.berat) + (6.25 * user.tinggi) - (5 * user.umur) + (5 if user.is_pria else -161)
    tdee = bmr * (1.2 + (user.frekuensi_olahraga * 0.1))

    if user.target_tubuh == "Menurunkan Berat Badan": target_kalori = tdee - 500
    elif user.target_tubuh == "Menaikkan Berat Badan": target_kalori = tdee + 400
    else: target_kalori = tdee

    t_sarapan = target_kalori * 0.25
    t_siang = target_kalori * 0.40
    t_malam = target_kalori * 0.35

    # 4. Sampling Menu berdasarkan Diet_Category dari MLP
    sarapan = get_sample_menu(df_menu, diet_category, t_sarapan * 0.7, t_sarapan * 1.3)
    siang = get_sample_menu(df_menu, diet_category, t_siang * 0.7, t_siang * 1.3)
    malam = get_sample_menu(df_menu, diet_category, t_malam * 0.7, t_malam * 1.3)

    return {
        "status_kesehatan": f"{diet_category} Diet (MLP AI)", 
        "insight_ai": f"Model MLP merekomendasikan kategori {diet_category}. Kalori dibagi ke 3 porsi makan harian.",
        "target_kalori_harian": round(target_kalori, 2), 
        "target_karbo_harian": round((target_kalori * 0.5) / 4, 2),
        "target_protein_harian": round((target_kalori * 0.25) / 4, 2),
        "target_lemak_harian": round((target_kalori * 0.25) / 9, 2),
        "kebutuhan_air_ml": round(user.berat * 35, 2), 
        "kebutuhan_air_gelas": int((user.berat * 35) / 250), 
        "skor_kesehatan": 100, 
        "porsi_makan": {
            "sarapan": {"target_kalori": round(t_sarapan, 2), "menu": _format_menu(sarapan, t_sarapan, "Sarapan")},
            "makan_siang": {"target_kalori": round(t_siang, 2), "menu": _format_menu(siang, t_siang, "Makan Siang")},
            "makan_malam": {"target_kalori": round(t_malam, 2), "menu": _format_menu(malam, t_malam, "Makan Malam")}
        }
    }

@app.post("/api/v1/regenerate-menu")
def regenerate_menu(req: RegenerateRequest):
    selected = get_sample_menu(df_menu, "Balanced", 100, 1000)
    return {"status": "success", "data": _format_menu(selected, 400, req.kategori)}