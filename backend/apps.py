from django.apps import AppConfig

#Define of the App Name
class BackendConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "backend"

    # import sinals
    def ready(self):
        import backend.signals