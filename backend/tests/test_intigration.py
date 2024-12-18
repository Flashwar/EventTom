from rest_framework.reverse import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth.models import User
from backend.models import Event, TicketTyp, Coupon


class EventIntegrationTests(APITestCase):
    # Set up resources required for integration tests,
    # including a test user, test event, test coupon, and test ticket type
    @classmethod
    def setUpTestData(cls):

        cls.user = User.objects.create_user(username="testuser", password="password123")
        cls.event = Event.objects.create(
            title="IntegrationTest Event",
            max_tickets=100,
            bought_tickets=10,
            threshold_tickets=20,
            base_price=50.00,
        )
        cls.coupon = Coupon.objects.create(owner=cls.user, amount=15.00)
        cls.ticket_typ = TicketTyp.objects.create(name="VIP", fee=0.14)

    def setUp(self):
        # Let user log in to obtain an access token for API requests
        login_response = self.client.post(
            reverse("token_obtain_pair"),  #
            {"username": "testuser", "password": "password123"},
            format="json",
        )
        self.assertEqual(login_response.status_code, status.HTTP_200_OK)
        self.access_token = login_response.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_token}")

    # Test: get all events
    def test_list_all_events(self):
        response = self.client.get(reverse("get_all_events"), format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)
        self.assertGreater(len(response.data), 0)
        self.assertEqual(response.data[0]["title"], "IntegrationTest Event")

    # Test: buy three tickets
    def test_ticket_booking(self):
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

    # Test: Attempt to purchase tickets for an event when the requested quantity exceeds the available stock
    def test_failed_ticket_booking_due_to_low_stock(self):

        response = self.client.post(
            reverse("ticket_booking"),
            {
                "customerID": self.user.id,
                "eventName": "IntegrationTest Event",
                "numberTickets": 500,
                "ticketTyp": "VIP",
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertIn("error", response.data)
        self.assertEqual(response.data["error"], "Not enough tickets available")

    # Test: Logout
    def test_logout(self):
        refresh_response = self.client.post(
            reverse("token_obtain_pair"),
            {"username": "testuser", "password": "password123"},
            format="json",
        )
        refresh_token = refresh_response.data.get("refresh", "dummy_token")
        logout_response = self.client.post(
            reverse("logout"),
            {"refresh": refresh_token},
            format="json"
        )
        self.assertEqual(logout_response.status_code, status.HTTP_200_OK)
        self.assertIn("message", logout_response.data)
        self.assertEqual(logout_response.data["message"], "successfully logged out")