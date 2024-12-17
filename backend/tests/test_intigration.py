from rest_framework.reverse import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth.models import User
from backend.models import Event, TicketTyp, Coupon


class EventIntegrationTests(APITestCase):
    @classmethod
    def setUpTestData(cls):
        # Gemeinsame Testdaten für Integrationstests
        cls.user = User.objects.create_user(username="testuser", password="password123")
        cls.event = Event.objects.create(
            title="IntegrationTest Event",
            max_tickets=100,
            bought_tickets=10,
            threshold_tickets=20,
            base_price=50.00,
        )
        cls.coupon = Coupon.objects.create(owner=cls.user, amount=15.00)
        cls.ticket_typ = TicketTyp.objects.create(name="VIP", fee=5.00)

    def setUp(self):
        # Einloggen des Users und Token speichern
        login_response = self.client.post(
            reverse("token_obtain_pair"),  # Korrekt
            {"username": "testuser", "password": "password123"},
            format="json",
        )
        self.assertEqual(login_response.status_code, status.HTTP_200_OK)
        self.access_token = login_response.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_token}")

    def test_list_all_events(self):
        """Test: Abrufen aller verfügbaren Events"""
        response = self.client.get(reverse("get_all_events"), format="json")  # Korrekt
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)
        self.assertGreater(len(response.data), 0)
        self.assertEqual(response.data[0]["title"], "IntegrationTest Event")

    def test_ticket_booking(self):
        """Test: Ticketbuchung für ein Event"""
        response = self.client.post(
            reverse("ticket_booking"),
            {
                "customerID": self.user.id,
                "eventName": "IntegrationTest Event",
                "numberTickets": 3,
                "ticketTyp": "VIP",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn("message", response.data)
        self.assertEqual(response.data["message"], "Tickets successfully booked")

    def test_failed_ticket_booking_due_to_low_stock(self):
        """Test: Fehlerhafte Buchung aufgrund unzureichender Tickets"""
        response = self.client.post(
            reverse("ticket_booking"),  # Geändert von hardcoded URL zu URL-Name
            {
                "customerID": self.user.id,
                "eventName": "IntegrationTest Event",
                "numberTickets": 500,  # Zu viele Tickets
                "ticketTyp": "VIP",
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertIn("error", response.data)
        self.assertEqual(response.data["error"], "Not enough tickets available")

    def test_logout(self):
        """Test: Benutzer abmelden durch Blacklisting des Tokens"""
        # Test-Abmeldung mit gültigem Refresh-Token
        refresh_response = self.client.post(
            reverse("token_obtain_pair"),  # Korrekt
            {"username": "testuser", "password": "password123"},
            format="json",
        )
        refresh_token = refresh_response.data.get("refresh", "dummy_token")
        logout_response = self.client.post(
            reverse("logout"),  # Geändert von hardcoded URL zu URL-Name
            {"refresh": refresh_token},
            format="json"
        )
        self.assertEqual(logout_response.status_code, status.HTTP_200_OK)
        self.assertIn("message", logout_response.data)
        self.assertEqual(logout_response.data["message"], "successfully logged out")