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
- **Pattern**: Dependency Injection für die Verwaltung von Abhängigkeiten

## Installation

Das Projekt umfasst eine Eventmanagement-Webseite, die es Nutzern ermöglicht, Tickets für verschiedene Events zu kaufen und dabei personalisierte Coupons zu erhalten. Darüber hinaus gibt es unterschiedliche Rollen, die verschiedene Funktionen innerhalb der Webseite haben:

Follow the steps below to set up the backend locally:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/backend-eventtom.git
   cd backend-eventtom
   
2. **Set Up a Virtual Environment (Optional): Create and activate a virtual environment for the project:**
    ```bash
        python -m venv venv
        source venv/bin/activate  # On Windows use `venv\Scripts\activate

3. **Install Requirements: Install the necessary Python packages:**

    ```bash
    pip install -r requirements.txt

## Debugging

Start the Django Server: Run the development server:
   ```bash
      python manage.py runserver
   ```
The Server will then be available locally on http://127.0.0.1:8000
