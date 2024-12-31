   FROM python:3.11

   WORKDIR /app

   # Installiere Systemabhängigkeiten und Git
   RUN apt-get update && apt-get install -y \
       git \
       && rm -rf /var/lib/apt/lists/*

       # Klone das Git-Repository
   RUN git clone https://github.com/Flashwar/EventTom.git .

   # Kopiere den kompletten Code
   COPY . .

   # Kopiere Anforderungen
   COPY requirements.txt .

   # Installiere Python-Abhängigkeiten
   RUN pip install --no-cache-dir -r requirements.txt


   CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]