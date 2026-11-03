# PorsiPas - Sistem Rekomendasi Diet Cerdas Berbasis AI

**Mata Kuliah:** Kecerdasan Buatan  
**Kode Kelas:** [ISI_KODE_KELAS_KAMU]  
**Kelompok:** [ISI_NOMOR_KELOMPOK]  

## 📖 Deskripsi Proyek
PorsiPas adalah sistem rekomendasi diet cerdas berbasis seluler (mHealth) yang menggunakan arsitektur *client-server*. Aplikasi seluler (Flutter) bertugas murni sebagai antarmuka, sementara seluruh komputasi kecerdasan buatan dijalankan secara terisolasi pada server *backend* (FastAPI). Algoritma **Multi Layer Perceptron (MLP)** digunakan untuk memetakan interaksi metrik biologis pengguna secara dinamis, termasuk variabel frekuensi olahraga.

## 👥 Anggota Tim & Kontribusi
1. **Tegar Riyadhi Alghifari** - 15240802 - **Peran:** AI Engineer, Model Training, FastAPI & Docker
2. **Ilyas Ar Rizqy** - 15240649 - **Peran:** Data Preprocessing, Documentation, QA Tester
3. **Maxswell Stefanus** - 15240753 - **Peran:** UI/UX Designer, Frontend Developer

## 🛠️ Prasyarat Lingkungan (Environment)
- **Sistem Operasi:** Windows 11
- **Backend:** Python 3.10.x, Docker Desktop + WSL2
- **Frontend:** Flutter SDK, Android Studio / VS Code

## 🚀 Quick Start (Cara Menjalankan Proyek)

### 1. Menjalankan Backend Server (Docker)
Buka terminal pada direktori proyek utama, lalu jalankan perintah berikut:
```bash
# 1. Build image Docker
docker build -t porsipas-backend:v1 .

# 2. Jalankan kontainer pada port 7860
docker run -d -p 7860:7860 --name container-porsipas porsipas-backend:v1

# 3. Publikasikan ke internet menggunakan Ngrok
ngrok http 7860
