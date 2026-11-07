from pydantic import BaseModel
from typing import Dict, Optional

class UserData(BaseModel):
    is_pria: bool
    umur: int
    tinggi: float
    berat: float
    frekuensi_olahraga: int  # 0, 1, 2, atau 3
    target_tubuh: str       # "Menurunkan Berat Badan", "Menjaga Berat Badan", "Menaikkan Berat Badan"

class MenuItem(BaseModel):
    nama: str
    kategori: str
    image_url: str
    karbohidrat: float
    protein: float
    lemak: float
    porsi_gram: int

class MealPortion(BaseModel):
    target_kalori: float
    menu: MenuItem

class DietRecommendationResponse(BaseModel):
    status_kesehatan: str
    insight_ai: str
    target_kalori_harian: float
    target_karbo_harian: float
    target_protein_harian: float
    target_lemak_harian: float
    kebutuhan_air_ml: float
    kebutuhan_air_gelas: int
    skor_kesehatan: int
    porsi_makan: Dict[str, MealPortion]