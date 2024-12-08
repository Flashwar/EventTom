from django.conf import settings
from django.urls import path

from backend import views

urlpatterns = [
    path('websocketTest/', views.websocket_test_view, name='websocket_test_view'),
]