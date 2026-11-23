from locust import HttpUser, task, between

class PorsiPasUser(HttpUser):
    wait_time = between(1, 3)

    @task(3)
    def test_predict_recommendation(self):
        payload = {
            "gender": "Male",
            "goal": "fat_burn",
            "bmi_cat": "Overweight",
            "exercise": "High-intensity interval training (HIIT), Cardio, and 8000 steps walking"
        }
        headers = {"Content-Type": "application/json"}
        # Tambahkan prefix jika ada, misal: /api/v1/predict
        self.client.post("/api/v1/predict", json=payload, headers=headers)

    @task(1)
    def test_health_check(self):
        # Sesuaikan endpoint health check, misal: /api/v1/health atau root /
        self.client.get("/api/v1/health")