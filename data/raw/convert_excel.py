import pandas as pd
import os

print("1. Memulai ekstraksi data dari seluruh Sheet TKPI.xlsx...")

excel_file = "tkpi_menu.xlsx"
csv_output = "tkpi_dataset.csv"

try:
    # Membaca seluruh file Excel
    xls = pd.ExcelFile(excel_file)
    
    # TKPI memiliki 13 sheet utama berisi makanan (indeks 0 sampai 12)
    # Sheet sisanya hanya berisi Glosari dan Kode yang tidak kita perlukan
    target_sheets = xls.sheet_names[:13] 
    
    all_data = []
    
    for sheet in target_sheets:
        df = pd.read_excel(xls, sheet_name=sheet)
        
        # Iterasi setiap baris di dalam sheet
        for index, row in df.iterrows():
            # Nama bahan makanan selalu ada di kolom ke-3 (index 2)
            name = row.iloc[2]
            
            # Abaikan jika sel kosong (NaN) atau berisi teks header/judul tabel
            if pd.isna(name) or name in ['NAMA BAHAN', 'MATANG', 'KODE BARU', 'MENTAH']:
                continue
                
            try:
                # Mengambil nilai Kalori, Protein, Lemak, dan Karbohidrat (berada di kolom indeks 5, 6, 7, 8)
                kalori = float(row.iloc[5]) if not pd.isna(row.iloc[5]) else 0.0
                protein = float(row.iloc[6]) if not pd.isna(row.iloc[6]) else 0.0
                lemak = float(row.iloc[7]) if not pd.isna(row.iloc[7]) else 0.0
                karbo = float(row.iloc[8]) if not pd.isna(row.iloc[8]) else 0.0
                
                all_data.append({
                    'menu': str(name).strip(),
                    'kalori': kalori,
                    'protein_g': protein,
                    'lemak_g': lemak,
                    'karbo_g': karbo
                })
            except ValueError:
                # Jika ada baris yang bukan angka, lewati saja
                pass

    # Mengubah seluruh data yang terkumpul menjadi DataFrame pandas
    tkpi_df = pd.DataFrame(all_data)
    
    # Pastikan folder tersedia
    os.makedirs("data/processed", exist_ok=True)
    
    # Menyimpan ke CSV
    tkpi_df.to_csv(csv_output, index=False)
    
    print(f"✅ Ekstraksi Selesai! Berhasil mengumpulkan {len(tkpi_df)} menu makanan dari {len(target_sheets)} kategori.")
    print(f"✅ File CSV telah disimpan di: {csv_output}")
    print("\nContoh 5 data pertama:")
    print(tkpi_df.head(5))
    
except Exception as e:
    print(f"❌ Terjadi kesalahan: {e}")