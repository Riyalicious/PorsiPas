import os
import shutil
import kagglehub

def download_all_food_datasets():
    # 1. Pastikan direktori data/raw/ sudah dibuat
    os.makedirs("data/raw", exist_ok=True)
    
    # 2. Daftar seluruh dataset Kaggle yang akan diunduh sekaligus
    datasets = [
        {
            "slug": "muliaprima/indonesian-food-nutrition",
            "filename": "indonesian_food_muliaprima.csv",
            "description": "Dataset Makanan & Nutrisi Lokal Indonesia (Muliaprima)"
        },
        {
            "slug": "ardikasatria/indonesian-food-nutrition-dataset",
            "filename": "indonesian_food_ardikasatria.csv",
            "description": "Dataset Makanan & Nutrisi Indonesia (Ardika Satria)"
        },
        {
            "slug": "niharika41298/nutrition-details-for-most-common-foods",
            "filename": "common_foods_nutrition.csv",
            "description": "Dataset Rincian Nutrisi Makanan Umum (Niharika)"
        },
        {
            "slug": "usda/food-data-central",
            "filename": "usda_food_data.csv",
            "description": "USDA Food Data Central (Official Standar Internasional)"
        }
    ]

    downloaded_files = []

    print("==================================================")
    print("Mulai Mengunduh Semua Dataset Makanan & Nutrisi...")
    print("==================================================\n")

    # 3. Looping pengunduhan setiap dataset
    for ds in datasets:
        slug = ds["slug"]
        target_filename = ds["filename"]
        desc = ds["description"]

        print(f"[+] Mengunduh: {desc} ({slug})...")
        try:
            # Unduh menggunakan library kagglehub
            path = kagglehub.dataset_download(slug)
            
            # Cari file CSV di dalam folder hasil unduhan
            csv_files = []
            for root, _, files in os.walk(path):
                for file in files:
                    if file.endswith('.csv'):
                        csv_files.append(os.path.join(root, file))
            
            if csv_files:
                # Ambil file CSV pertama yang ditemukan
                source_csv = csv_files[0]
                dest_path = os.path.join("data/raw", target_filename)
                shutil.copy(source_csv, dest_path)
                print(f"    -> BERHASIL! Disimpan sebagai: {dest_path}\n")
                downloaded_files.append(dest_path)
            else:
                print(f"    -> PERINGATAN: Tidak ditemukan file .csv pada folder {path}\n")

        except Exception as e:
            print(f"    -> GAGAL mengunduh {slug}: {e}\n")

    # 4. Atur dataset utama Makanan Indonesia sebagai 'data/raw/food_dataset.csv' untuk FastAPI
    primary_indonesian = os.path.join("data/raw", "indonesian_food_muliaprima.csv")
    default_target = os.path.join("data/raw", "food_dataset.csv")

    if os.path.exists(primary_indonesian):
        shutil.copy(primary_indonesian, default_target)
        print(f"[✓] Berhasil menetapkan '{primary_indonesian}' sebagai 'data/raw/food_dataset.csv' (Default Backend).")
    elif downloaded_files:
        shutil.copy(downloaded_files[0], default_target)
        print(f"[✓] Berhasil menetapkan '{downloaded_files[0]}' sebagai 'data/raw/food_dataset.csv' (Default Backend).")

    print("\n==================================================")
    print("Selesai! Seluruh dataset telah tersimpan di folder data/raw/")
    print("==================================================")

if __name__ == "__main__":
    download_all_food_datasets()