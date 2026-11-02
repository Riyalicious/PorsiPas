# Gunakan Python 3.11-slim agar sesuai dengan environment Python lokal
FROM python:3.11-slim

# Set direktori kerja di dalam kontainer
WORKDIR /code

# Salin requirements.txt dan instal pustaka tanpa menyimpan cache
COPY requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Salin direktori aplikasi, model, dan data
COPY ./app /code/app
COPY ./models /code/models
COPY ./data /code/data

# Expose port kontainer
EXPOSE 7860

# Jalankan server Uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]