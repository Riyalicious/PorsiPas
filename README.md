# PorsiPas - Sistem Rekomendasi Diet Cerdas Berbasis AI

**Mata Kuliah:** Kecerdasan Buatan, Machine Learning, Penilitan Ilmu Komputer  
**Kode Kelas:** 15.5B.05  
**Kelompok:** Kelompok 6  

## 📖 Deskripsi Proyek
PorsiPas adalah sistem rekomendasi diet cerdas berbasis seluler (*mHealth*) yang mengimplementasikan arsitektur *client-server*. Aplikasi seluler (Flutter) bertugas murni sebagai antarmuka pengguna, sementara beban komputasi *Machine Learning* dijalankan secara terisolasi pada *backend server* berbasis FastAPI. Sistem menggunakan algoritma **Multi Layer Perceptron (MLP)** untuk memetakan metrik fisik pengguna secara dinamis, termasuk tingkat frekuensi olahraga.

## 👥 Anggota Tim & Kontribusi
* **Ilyas Ar Rizqy** - 15240753
  * *Peran:* Data Preprocessing, Documentation, QA Tester
* **Maxswell Stefanus** - 15240753
  * *Peran:* UI/UX Designer, Frontend Developer
* **Tegar Riyadhi Alghifari** - 15240802
  * *Peran:* AI Engineer, Model Training, FastAPI & Docker Integration

## 🛠️ Prasyarat Lingkungan (Environment)
- **Sistem Operasi:** Windows 10/11
- **Tools Utama:** Python 3.10.x, VS Code, Git, Docker Desktop + WSL2
- **Mobile SDK:** Flutter SDK, Android Studio / Emulator
- **Virtual Environment:** Python `.venv`

## 🚀 Quick Start (Panduan Jalankan Proyek)

### 1. Inisialisasi Backend Lokal (Opsional untuk Testing Non-Docker)
Jika ingin menjalankan backend Python secara manual tanpa kontainer:
```bash
# Buat dan aktifkan Virtual Environment
py -m venv .venv
.venv\Scripts\activate

# Install dependensi
pip install -r requirements.txt

# Jalankan server Uvicorn secara lokal
uvicorn app.main:app --reload --host 0.0.0.0 --port 7861
```

### 2. Menjalankan Backend via Docker Container (Sesuai Standar Penilaian)
Di dalam kontainer Docker, perintah `uvicorn` sudah dikonfigurasi secara otomatis melalui `CMD` pada `Dockerfile`.
```bash
# 1. Pastikan Docker Desktop & WSL2 sudah aktif di Windows

# 2. Build Docker Image
docker build -t porsipas-backend:v1 .

# 3. Jalankan Kontainer pada Port 7860
docker run -d -p 7860:7860 --name container-porsipas porsipas-backend:v1

# 4. Verifikasi Backend Berjalan
# Buka browser di http://localhost:7860/docs (Swagger UI)
```

### 3. Expose Server ke Publik (Ngrok)
Agar aplikasi seluler/emulator dapat mengakses backend lokal melalui jalur publik:
```bash
ngrok http 7860
```
*(Salin URL HTTPS yang dihasilkan, contoh: `[https://xxxx.ngrok-free.app](https://xxxx.ngrok-free.app)`)*

### 4. Menjalankan Aplikasi Mobile (Flutter)
```bash
# 1. Masuk ke folder mobile
cd mobile

# 2. Buka file lib/services/api_service.dart dan ganti variabel baseUrl:
# static const String baseUrl = "https://URL-NGROK-TERBARU.ngrok-free.app";

# 3. Unduh dependensi Flutter
flutter pub get

# 4. Jalankan aplikasi
flutter run
```
