<div align="center">
  <h1>🍽️ PorsiPas</h1>
  <p><b>Sistem Rekomendasi Diet Cerdas Berbasis AI</b></p>
  
  ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
  ![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi&logoColor=white)
  ![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
</div>

---

## 📚 Informasi Akademik
- **Mata Kuliah:** Kecerdasan Buatan, Machine Learning, Penelitian Ilmu Komputer  
- **Kode Kelas:** 15.5B.05  
- **Kelompok:** Kelompok 6  

## 📖 Deskripsi Proyek
**PorsiPas** adalah sistem rekomendasi diet cerdas berbasis seluler (*mHealth*) yang mengimplementasikan arsitektur *client-server*. 

Aplikasi seluler (Flutter) bertugas murni sebagai antarmuka pengguna, sementara beban komputasi *Machine Learning* dijalankan secara terisolasi pada *backend server* berbasis FastAPI. Sistem menggunakan algoritma **Multi-Layer Perceptron (MLP)** untuk memetakan metrik fisik pengguna secara dinamis, termasuk tingkat frekuensi olahraga, dan memberikan rekomendasi menu makanan yang presisi.

## 👥 Anggota Tim & Kontribusi
| Nama | NIM | Peran Utama |
| :--- | :--- | :--- |
| **Ilyas Ar Rizqy** | 15240753 | Data Preprocessing, Documentation, QA Tester |
| **Maxswell Stefanus** | 15240753 | UI/UX Designer, Frontend Developer |
| **Tegar Riyadhi Alghifari** | 15240802 | AI Engineer, Model Training, FastAPI & Docker Integration |

## 🛠️ Prasyarat Lingkungan (Environment)
Pastikan sistem Anda memenuhi spesifikasi berikut sebelum menjalankan proyek:
- **Sistem Operasi:** Windows 10/11
- **Tools Utama:** Python 3.10.x, VS Code, Git, Docker Desktop + WSL2
- **Mobile SDK:** Flutter SDK, Android Studio / Emulator
- **Virtual Environment:** Python `.venv`

---

## 🚀 Panduan Instalasi & Menjalankan (Quick Start)

### 1. Menjalankan Backend via Docker Container (Standar Penilaian)
Di dalam kontainer Docker, perintah `uvicorn` sudah dikonfigurasi secara otomatis melalui `CMD` pada `Dockerfile`.

```bash
# 1. Pastikan Docker Desktop & WSL2 sudah aktif di Windows

# 2. Build Docker Image
docker build -t porsipas-backend:v1 .

# 3. Jalankan Kontainer pada Port 7860
docker run -d -p 7860:7860 --name container-porsipas porsipas-backend:v1

# 4. Verifikasi Backend Berjalan
# Buka browser ke: http://localhost:7860/docs (Swagger UI)
```

### 2. Expose Server ke Publik (Ngrok)
Agar aplikasi seluler/emulator dapat mengakses backend lokal melalui jalur publik:

```bash
ngrok http 7860
```
*Catat dan salin URL HTTPS yang dihasilkan oleh Ngrok (contoh: `https://xxxx.ngrok-free.app`).*

### 3. Menjalankan Aplikasi Mobile (Flutter)
Hubungkan aplikasi seluler ke backend yang telah terekspos.

```bash
# 1. Masuk ke direktori mobile
cd mobile

# 2. Buka file konfigurasi API
# Path: lib/services/api_service.dart
# Edit variabel baseUrl dengan URL Ngrok terbaru:
# static const String baseUrl = "https://URL-NGROK-TERBARU.ngrok-free.app";

# 3. Unduh dependensi Flutter
flutter pub get

# 4. Jalankan aplikasi pada emulator atau perangkat fisik
flutter run
```

---

### 💡 Alternatif: Inisialisasi Backend Lokal (Non-Docker)
Jika ingin melakukan pengujian backend Python secara manual tanpa kontainer:

```bash
# Buat dan aktifkan Virtual Environment
py -m venv .venv
.venv\Scripts\activate

# Install dependensi
pip install -r requirements.txt

# Jalankan server Uvicorn secara lokal pada port 7861
uvicorn app.main:app --reload --host 0.0.0.0 --port 7861
```
