from django.urls import path

from . import consumers

# Define the WebSocket URLs for communication with clients
websocket_urlpatterns = [
    # WS to notify online Eventmanager about tickets purchases
    path('ws/admin/notifications/', consumers.AdminNotificationConsumer.as_asgi()),

    # WS for notify the client about new events or updates about the available tickets of an event
    path('ws/event/update/', consumers.EventConsumer.as_asgi()),
]
