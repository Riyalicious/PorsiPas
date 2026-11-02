from locust import HttpUser, task, between
import random

class PorsiPasUser(HttpUser):
    # Waktu tunggu simulasi user (1 hingga 2 detik)
    wait_time = between(1, 2)

    @task
    def test_predict_diet(self):
        # Mensimulasikan data JSON persis seperti dari Flutter
        payload = {
            "umur": random.randint(15, 60),
            "tinggi": random.uniform(150.0, 185.0),
            "berat": random.uniform(45.0, 95.0),
            "frekuensi_olahraga": random.randint(0, 3),
            "jenis_kelamin": random.choice(["pria", "wanita"]),
            "target_tubuh": "sedang" 
        }
        
        headers = {'Content-Type': 'application/json'}
        
        # Simulasi Hit (request) ke endpoint POST predict
        with self.client.post("/api/v1/predict", json=payload, headers=headers, catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Error {response.status_code}: {response.text}")