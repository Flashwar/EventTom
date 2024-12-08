from django.urls import path
from . import consumers


websocket_urlpatterns = [
    path('ws/admin/notifications/', consumers.AdminNotificationConsumer.as_asgi()),
    path('ws/event/update/', consumers.EventConsumer.as_asgi()),
]
