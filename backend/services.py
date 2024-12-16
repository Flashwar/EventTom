from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from injector import singleton

from EventTom import settings
from backend.models import Event, Ticket, Coupon, TicketTyp, Employee


# Singleton class for managing event-related operations
@singleton
class EventService:
    # Retrieves an event by its title from the database
    def get_event_by_title(self, event_title):
        try:
            # Retrieves an event by its title from the database
            return Event.objects.get(title=event_title)
        except Event.DoesNotExist:
            # Return None if no event with the specified title exists
            return None

    # Creates a new event
    def create_event(self, event_data):
        try:
            # create an event object and store it in the database
            return Event.objects.create(
                title=event_data['title'],
                max_tickets=event_data['max_tickets'],
                bought_tickets=event_data['bought_tickets'],
                threshold_tickets=event_data['threshold_tickets'],
                base_price=float(event_data['base_price'])
            )
        except Exception as _:
            # Return None if creation fails
            return None

    # Retrieve all events from the databse
    def get_all_events(self):
        try:
            # Get all event model instances
            return Event.objects.all()
        except Exception as _:
            return None


# Singleton class for managing user-related operations
@singleton
class UserService:
    # Retrieves a user by their unique ID
    def get_user_by_id(self, user_id):
        try:
            # Query the user by their id
            return User.objects.get(id=user_id)
        except User.DoesNotExist:
            # Return None if no user with the specified ID exists
            return None

    # Retrieves a user by their username
    def get_user_by_username(self, username):
        try:
            # Query the user by their username
            return User.objects.get(username=username)
        except User.DoesNotExist:
            return None

    # check if a username already exists in the database
    def check_if_username_exists(self, username):
        # Returns True if the username exists
        return User.objects.filter(username=username).exists()

    # Creates a new user
    def create_user(self, username, password, email, firstname, lastname):
        try:
            return User.objects.create(
                username=username,
                # Hashes the password before storing it
                password=make_password(password),
                email=email,
                firstname=firstname,
                lastname=lastname
            )
        except Exception as _:
            # Return None if user creation fails
            return None


# Singleton class for managing employee-related operations
@singleton
class EmployeeService:
    # Retrieves an employee by their unique staff number
    def get_employee(self, staff_number: str):
        try:
            # Query for the employee
            return Employee.objects.get(staff_number=staff_number)
        except Employee.DoesNotExist:
            # Return None if no employee with the given staff number exists
            return None


# Singleton class for managing coupon-related operations
@singleton
class CouponService:
    # Retrieves a coupon by its ID and validates ownership by username
    def get_coupon(self, coupon_id, owner_username):
        try:
            # Query for the coupon by its ID
            coupon = Coupon.objects.get(id=coupon_id)
            # Validate if the coupon owner matches the username
            if str(coupon.owner) != str(owner_username):
                return None, {"error": "The coupon isn't owned by the user"}
            # Return the coupon if the owner matches
            return coupon, None
        except Coupon.DoesNotExist:
            # Return an error if the coupon does not exist
            return None, {"error": "Coupon not found"}

    # Retrieves all coupons owned by a specific user
    def get_coupons_by_owner(self, owner_id):
        try:
            # Query for coupons with the given owner ID
            return Coupon.objects.filter(owner_id=owner_id)
        except Coupon.DoesNotExist:
            # Return None if no coupons are found
            return None


# Singleton class for managing tickettyp-related operations
@singleton
class TicketTypService:
    # Retrieves a ticket type by its name
    def get_ticket_type(self, ticket_type_name):
        try:
            # Query for the ticket type by name
            return TicketTyp.objects.get(name=ticket_type_name)
        except TicketTyp.DoesNotExist:
            # Return None if the ticket type does not exist
            return None

    # Retrieves all available ticket types
    def get_all_ticket_types(self):
        try:
            # Return a queryset of all ticket types
            return TicketTyp.objects.all()
        except Exception as _:
            # if something happened return None
            return None


# Singleton class for managing ticket-related operations
@singleton
class TicketService:
    # Creates a ticket and calculates the price
    def create_ticket(self, customer, event, ticket_type, num_tickets, coupon_value, coupon=None):
        price = ((event.base_price + (event.base_price * ticket_type.fee)) * num_tickets) - coupon_value

        # Create the ticket with
        Ticket.objects.create(
            owner=customer,
            ticket_typ=ticket_type,
            event=event,
            numb_tickets=num_tickets,
            price=price
        )

        # If a coupon is used and not in debug mode, delete the coupon after use
        if coupon and not settings.DEBUG:
            coupon.delete()
