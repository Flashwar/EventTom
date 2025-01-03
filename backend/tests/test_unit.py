from django.test import TestCase
from django.contrib.auth.models import User
from backend.models import Event, TicketTyp, Coupon
from backend.services import EventService, UserService, CouponService, TicketTypService


class EventServiceTests(TestCase):
    # Initialize the EventService and create a sample event for testing
    def setUp(self):
        self.event_service = EventService()
        self.event = Event.objects.create(
            title="UnitTest Event",
            max_tickets=100,
            bought_tickets=10,
            threshold_tickets=20,
            base_price=60.00,
        )

    # Test: fetching an event by its title
    def test_get_event_by_title(self):
        event = self.event_service.get_event_by_title("UnitTest Event")
        self.assertIsNotNone(event, "Event should not be None")
        self.assertEqual(event.title, "UnitTest Event")

    # Test: creating a new event
    def test_create_event(self):
        event_data = {
            "title": "New Event",
            "max_tickets": 50,
            "bought_tickets": 0,
            "threshold_tickets": 10,
            "base_price": 40.00,
        }
        created_event = self.event_service.create_event(event_data)
        self.assertIsNotNone(created_event, "Event creation failed")
        self.assertEqual(created_event.title, "New Event")


class UserServiceTests(TestCase):
    # Initialize the UserService and create a test user
    def setUp(self):
        self.user_service = UserService()
        self.user = User.objects.create_user(username="testuser", password="password123")

    # Test: if an existing username can be found
    def test_check_if_username_exists(self):
        self.assertTrue(self.user_service.check_if_username_exists("testuser"))
        self.assertFalse(self.user_service.check_if_username_exists("nonexistentuser"))


class CouponServiceTests(TestCase):
    # Initialize the CouponService and create a test coupon for a user
    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="password123")
        self.coupon_service = CouponService()
        self.coupon = Coupon.objects.create(owner=self.user, amount=20.00)

    # Test: retrieving a valid coupon by ID and username and validate the ownership
    # Test: retrieving an invalid coupon
    def test_get_coupon(self):
        coupon, error = self.coupon_service.get_coupon(self.coupon.id, "testuser")
        self.assertIsNotNone(coupon)
        self.assertIsNone(error)

        _, error = self.coupon_service.get_coupon(9999, "testuser")
        self.assertIsNotNone(error)


class TicketTypServiceTests(TestCase):
    # Initialize the TicketTypService and create a sample ticket type
    def setUp(self):
        self.ticket_typ_service = TicketTypService()
        self.ticket_typ = TicketTyp.objects.create(name="Standard", fee=5.00)

    # Test: fetching a ticket type by name
    def test_get_ticket_type(self):
        ticket_type = self.ticket_typ_service.get_ticket_type("Standard")
        self.assertIsNotNone(ticket_type)
        self.assertEqual(ticket_type.name, "Standard")

    # Test: fetching a nonexistent ticket type
    def test_get_invalid_ticket_type(self):
        ticket_type = self.ticket_typ_service.get_ticket_type("Nonexistent")
        self.assertIsNone(ticket_type)
