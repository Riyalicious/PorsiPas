import pandas as pd
import os

data = [
    {"nama_makanan": "Nasi Putih (1 Porsi)", "kalori": 175, "protein": 3.0, "lemak": 0.4, "karbohidrat": 40.0},
    {"nama_makanan": "Dada Ayam Panggang (100g)", "kalori": 165, "protein": 31.0, "lemak": 3.6, "karbohidrat": 0.0},
    {"nama_makanan": "Tempe Goreng (2 Potong)", "kalori": 120, "protein": 8.0, "lemak": 7.0, "karbohidrat": 6.0},
    {"nama_makanan": "Tahu Bacem (2 Potong)", "kalori": 100, "protein": 6.0, "lemak": 4.0, "karbohidrat": 10.0},
    {"nama_makanan": "Telur Rebus (1 Butir)", "kalori": 78, "protein": 6.3, "lemak": 5.3, "karbohidrat": 0.6},
    {"nama_makanan": "Sayur Bening Bayam (1 Mangkok)", "kalori": 50, "protein": 2.0, "lemak": 0.5, "karbohidrat": 8.0},
    {"nama_makanan": "Tumis Brokoli Wortel", "kalori": 85, "protein": 3.0, "lemak": 4.0, "karbohidrat": 9.0},
    {"nama_makanan": "Ikan Nila Bakar (1 Ekor)", "kalori": 190, "protein": 26.0, "lemak": 8.0, "karbohidrat": 0.0},
    {"nama_makanan": "Oatmeal Polos (1 Mangkok)", "kalori": 150, "protein": 5.0, "lemak": 2.5, "karbohidrat": 27.0},
    {"nama_makanan": "Pisang Ambon (1 Buah)", "kalori": 105, "protein": 1.3, "lemak": 0.3, "karbohidrat": 27.0}
]

os.makedirs("data/raw", exist_ok=True)
df = pd.DataFrame(data)
df.to_csv("data/raw/food_dataset.csv", index=False)
print("Dataset Makanan Indonesia berhasil dibuat di data/raw/food_dataset.csv!")