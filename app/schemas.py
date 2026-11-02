from pydantic import BaseModel
from typing import List, Optional

# Skema Request Input dari Flutter
class UserData(BaseModel):
    is_pria: bool
    umur: int
    tinggi: float
    berat: float
    frekuensi_olahraga: int  # 0, 1, 2, atau 3
    target_tubuh: str       # "Menurunkan Berat Badan", "Menjaga Berat Badan", "Menaikkan Berat Badan"

# Skema Sub-item Menu
class MenuItem(BaseModel):
    nama: str
    kategori: str
    image_url: str
    karbohidrat: float
    protein: float
    lemak: float

class MealPortion(BaseModel):
    target_kalori: float
    menu: MenuItem

# Skema Response Output dari FastAPI
class DietRecommendationResponse(BaseModel):
    status_kesehatan: str
    target_kalori_harian: float
    kebutuhan_air_ml: float
    kebutuhan_air_gelas: int
    skor_kesehatan: int
    porsi_makan: dict