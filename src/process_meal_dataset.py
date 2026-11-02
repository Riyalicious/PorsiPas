import os
import pandas as pd

def create_categorized_meal_dataset():
    processed_dir = "data/processed"
    os.makedirs(processed_dir, exist_ok=True)

    # Dataset 36 Menu Sehat Terkategori lengkap dengan URL Gambar (CDN Unsplash)
    curated_meals = [
        # ==================== SARAPAN (BREAKFAST) ====================
        {
            "nama_makanan": "Oatmeal Pisang & Madu", "kalori": 250, "protein": 8.0, "lemak": 4.0, "karbohidrat": 48.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1517673400267-0251440c45dc?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Roti Gandum Telur Dadar & Alpukat", "kalori": 320, "protein": 14.0, "lemak": 12.0, "karbohidrat": 38.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Bubur Ayam Bening (Tanpa Kerupuk)", "kalori": 280, "protein": 16.0, "lemak": 6.0, "karbohidrat": 40.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1541832676-9b763b0239ab?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Smoothie Pisang Buah Naga & Chia Seeds", "kalori": 210, "protein": 6.0, "lemak": 3.0, "karbohidrat": 42.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Telur Rebus (2 Butir) & Kentang Rebus", "kalori": 230, "protein": 14.0, "lemak": 10.0, "karbohidrat": 22.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Omelet Sayur Bayam & Roti Gandum", "kalori": 270, "protein": 15.0, "lemak": 11.0, "karbohidrat": 28.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Lontong Sayur Labu Siam (Tanpa Santan)", "kalori": 220, "protein": 6.0, "lemak": 5.0, "karbohidrat": 38.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Pancake Oatmeal & Potongan Apel", "kalori": 260, "protein": 9.0, "lemak": 4.0, "karbohidrat": 46.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Sandwich Dada Ayam & Selada", "kalori": 310, "protein": 24.0, "lemak": 6.0, "karbohidrat": 39.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Greek Yogurt Granola & Buah Segar", "kalori": 240, "protein": 12.0, "lemak": 5.0, "karbohidrat": 37.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Ubi Jalar Rebus & Telur Ceplok Air", "kalori": 250, "protein": 9.0, "lemak": 6.0, "karbohidrat": 40.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Nasi Merah + Orek Tempe Basah", "kalori": 290, "protein": 11.0, "lemak": 7.0, "karbohidrat": 45.0, "kategori_waktu": "sarapan",
            "gambar_url": "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80"
        },

        # ==================== MAKAN SIANG (LUNCH) ====================
        {
            "nama_makanan": "Nasi Merah + Dada Ayam Panggang + Tumis Brokoli", "kalori": 420, "protein": 38.0, "lemak": 8.0, "karbohidrat": 50.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1543339308-43e59d6b73a6?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Nasi Putih + Pepes Ikan Mas + Sayur Asem", "kalori": 380, "protein": 30.0, "lemak": 7.0, "karbohidrat": 48.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Gado-Gado Telur & Tahu (Bumbu Tipis)", "kalori": 350, "protein": 18.0, "lemak": 12.0, "karbohidrat": 42.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Nasi Merah + Tumis Tahu Tempe + Sayur Bayam", "kalori": 340, "protein": 16.0, "lemak": 8.0, "karbohidrat": 52.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Kentang Panggang + Daging Sapi Tumis Cabe Hijau", "kalori": 410, "protein": 32.0, "lemak": 10.0, "karbohidrat": 48.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1603048588665-791ca8aea617?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Nasi Merah + Ayam Kukus Bumbu Kuning + Lalapan", "kalori": 390, "protein": 35.0, "lemak": 7.0, "karbohidrat": 46.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Sop Ayam Kampung Bening + Nasi Merah", "kalori": 360, "protein": 28.0, "lemak": 8.0, "karbohidrat": 44.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Pepes Tahu Jamur + Nasi Merah + Sayur Capcay", "kalori": 320, "protein": 15.0, "lemak": 6.0, "karbohidrat": 52.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Nasi Jagung + Ikan Bakar Sambal Dabu-Dabu", "kalori": 370, "protein": 31.0, "lemak": 6.0, "karbohidrat": 49.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Salmon Panggang + Salad Sayur Segar", "kalori": 450, "protein": 34.0, "lemak": 18.0, "karbohidrat": 36.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Nasi Merah + Semur Tahu & Telur Rebus", "kalori": 360, "protein": 19.0, "lemak": 9.0, "karbohidrat": 51.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Bihun Goreng Jagung + Suwir Dada Ayam", "kalori": 380, "protein": 26.0, "lemak": 8.0, "karbohidrat": 51.0, "kategori_waktu": "makan_siang",
            "gambar_url": "https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=600&q=80"
        },

        # ==================== MAKAN MALAM (DINNER) ====================
        {
            "nama_makanan": "Sup Kimlo Ayam & Jamur Kuping", "kalori": 280, "protein": 22.0, "lemak": 5.0, "karbohidrat": 36.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Salad Dada Ayam Panggang & Olive Oil", "kalori": 310, "protein": 30.0, "lemak": 9.0, "karbohidrat": 26.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Tumis Buncis Daging Cincang + Kentang Rebus", "kalori": 330, "protein": 24.0, "lemak": 8.0, "karbohidrat": 40.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1603048588665-791ca8aea617?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Steak Tempe Panggang + Tumis Asparagus", "kalori": 270, "protein": 16.0, "lemak": 9.0, "karbohidrat": 32.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Pepes Ikan Gurame + Cah Kangkung Bawang Putih", "kalori": 290, "protein": 28.0, "lemak": 7.0, "karbohidrat": 28.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Nasi Merah ½ Porsi + Tumis Jamur Tiram Tahu", "kalori": 260, "protein": 12.0, "lemak": 5.0, "karbohidrat": 42.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Sup Daging Bening Rendah Lemak + Wortel", "kalori": 320, "protein": 26.0, "lemak": 8.0, "karbohidrat": 35.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Dada Ayam Kukus Lemon + Mashed Potato", "kalori": 340, "protein": 32.0, "lemak": 6.0, "karbohidrat": 38.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1532550907401-a500c9a57435?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Capcay Kuah Seafood (Udang & Cumi)", "kalori": 290, "protein": 27.0, "lemak": 6.0, "karbohidrat": 32.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Sate Ayam Tanpa Kulit (Bumbu Kacang Tipis)", "kalori": 320, "protein": 28.0, "lemak": 10.0, "karbohidrat": 30.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Tumis Brokoli Tahu Bawang Putih", "kalori": 230, "protein": 11.0, "lemak": 6.0, "karbohidrat": 33.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80"
        },
        {
            "nama_makanan": "Omelet Putih Telur + Selada & Tomat", "kalori": 210, "protein": 20.0, "lemak": 4.0, "karbohidrat": 22.0, "kategori_waktu": "makan_malam",
            "gambar_url": "https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=600&q=80"
        }
    ]

    df_curated = pd.DataFrame(curated_meals)
    output_path = os.path.join(processed_dir, "food_database.csv")
    df_curated.to_csv(output_path, index=False)

    print("\n==================================================")
    print("DATABASE MAKANAN LENGKAP DENGAN URL GAMBAR BERHASIL DIPERBARUI!")
    print("==================================================")
    print(df_curated['kategori_waktu'].value_counts())
    print(f"[✓] File tersimpan di: {output_path}\n")

if __name__ == "__main__":
    create_categorized_meal_dataset()