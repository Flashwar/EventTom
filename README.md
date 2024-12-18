# EvenTom Semesterprojekt Softwarearchitektur und Qualitätssicherung WS 2024/2025

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Flashwar_EventTom&metric=alert_status&token=a25909191128104ff274039bdfb1e587b31b8457)](https://sonarcloud.io/summary/new_code?id=Flashwar_EventTom)


Dieses Repository stellt das GitHub-Mirror-Repo für das Eventmanagement-Projekt EventTom dar, das nebenbei auf GitLab gehostet wird. Das Projekt wurde im Rahmen des Semesters "Softwarearchitektur und Qualitätssicherung" im Wintersemester 2024/2025 entwickelt.

## Projektbeschreibung

Das Projekt umfasst eine Eventmanagement-Webseite, die es Nutzern ermöglicht, Tickets für verschiedene Events zu kaufen und dabei personalisierte Coupons zu erhalten. Darüber hinaus gibt es unterschiedliche Rollen, die verschiedene Funktionen innerhalb der Webseite haben:

- **Kunde**: Kann ein oder mehrere Tickets kaufen und personalisierte Coupons erhalten.
- **Employee**: Hat bestimmte Berechtigungen für die Verwaltung von Events.
- **EventManager**: Wird benachrichtigt, wenn Tickets für ein Event gekauft wurden.
- **EventCreator**: Kann neue Events erstellen. Sobald ein neues Event erstellt wird, werden alle aktiven Nutzer benachrichtigt.

### Benachrichtigungsfunktionen:
- **EventCreator**: Alle aktiven Nutzer werden benachrichtigt, wenn ein neues Event erstellt wird.
- **Ticketkauf**: Alle aktiven EventManager werden benachrichtigt, wenn Tickets für ein Event gekauft werden, und erhalten die Information, wie viele Tickets für welches Event gekauft wurden.

## Verwendete Technologien

- **Frontend**: Flutter
- **Backend**: Django
- **API**: Restful Framework mit JWT (JSON Web Tokens) für Authentifizierung
- **Websockets**: Für Echtzeit-Kommunikation
- **Datenbank**: PostgreSQL (DBMS)
- **Redis**: Wird für Websockets (Channels) verwendet, um Echtzeit-Benachrichtigungen zu ermöglichen
- **Pattern**: Dependency Injection, Observer, Decorator und Singelton

## Installation des Backends:

## Installation

### Backend Setup mit Poetry

1. **Repository klonen:**
   ```bash
   git clone https://github.com/yourusername/backend-eventtom.git
   cd backend-eventtom
   ```

   2. **Poetry installieren:**
   Wenn Poetry noch nicht installiert ist, kannst du es mit folgendem Befehl einrichten:
      ```bash
      curl -sSL https://install.python-poetry.org | python3 -
      ```
      Alternativ, lies die [offizielle Dokumentation](https://python-poetry.org/docs/#installation) für detaillierte Anweisungen.

3. **Abhängigkeiten installieren:**
   Nach der Installation von Poetry kann man alle Abhängigkeiten des Projekts mit einem einfachen Befehl installieren:
   ```bash
   poetry install
   ```

4. **Projektumgebung aktivieren:**
   ```bash
   poetry shell
   ```

5. **Django-Server starten:**
   Nachdem die Installation abgeschlossen ist, kann der Server wie folgt gestartet werden:
   ```bash
   python manage.py runserver
   ```

### Alternative: Backend Setup mit virtueller Umgebung (venv)

1. **Virtuelle Umgebung erstellen und aktivieren:**
   ```bash
   python -m venv venv
   source venv/bin/activate   # Windows: `venv\Scripts\activate`
   ```

2. **Abhängigkeiten mit `pip` installieren:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Django-Server starten:**
   Starte den Entwicklungsserver mit:
   ```bash
   python manage.py runserver
   ```

## Testen des Projekts

Das Projekt verwendet Django-integrierte Test-Frameworks. Um sicherzustellen, dass alle Funktionen korrekt funktionieren, können Tests wie folgt ausgeführt werden:

### Tests ausführen mit Poetry-Setup:
1. Stelle sicher, dass du dich in der Poetry-Umgebung befindest (`poetry shell`).
2. Führe die Tests aus:
   ```bash
   python manage.py test backend.tests
   ```

### Tests ausführen mit virtueller Umgebung:
1. Aktiviere die virtuelle Umgebung (`source venv/bin/activate` oder `venv\Scripts\activate` je nach Betriebssystem).
2. Führe die Tests aus:
   ```bash
   python manage.py test backend.tests
   ```

## Starten des Servers

Um die lokale Entwicklungsumgebung zu starten, führe den folgenden Befehl aus:

```bash
python manage.py runserver
```

Der Server ist dann unter `http://127.0.0.1:8000` erreichbar.