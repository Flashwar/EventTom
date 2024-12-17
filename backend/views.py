from django.db import transaction
from injector import inject
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.tokens import RefreshToken

from backend.permissions import IsEventCreator
from backend.serializers import EventSerializer, CouponSerializer, TicketTypSerializer
from backend.services import CouponService, UserService, EventService, TicketTypService, TicketService, EmployeeService


# EventInfoView allows creating a new event
class EventInfoView(APIView):
    serializer_class = EventSerializer
    # Only EventCreator are allowed to create an event
    permission_classes = [IsEventCreator]

    @inject
    def __init__(self, event_service: EventService):
        self.event_service = event_service

    def post(self, request):
        serializer = EventSerializer(data=request.data)
        # Validate incoming data and create an event
        if serializer.is_valid():
            with transaction.atomic():
                event = self.event_service.create_event(serializer.validated_data)
            # A notification will be sent to all user via notify_event_creation_or_update
            if event is None:
                return Response({"error": "Error creating event"}, status=status.HTTP_409_CONFLICT)

            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Listing all Events
class EventListView(APIView):
    serializer_class = EventSerializer
    # Allow everyone to access this endpoint
    permission_classes = [AllowAny]

    @inject
    def __init__(self, event_service: EventService):
        self.event_service = event_service

    def get(self, request):
        # get all events
        events = self.event_service.get_all_events()

        # check if the event object is none
        if events is None:
            return Response({"error": "An error occurred while fetching ticket types"},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # serialize all the ticket objects and return it
        serializer = EventSerializer(events, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)


# EventDetailView retrieves a specific event based on its title
class EventDetailView(APIView):
    serializer_class = EventSerializer
    authentication_classes = [JWTAuthentication]
    # Only authenticated users can access this
    permission_classes = [IsAuthenticated]

    @inject
    def __init__(self, event_service: EventService):
        self.event_service = event_service

    def get(self, request):
        # Search for an event with the given title
        event = self.event_service.get_event_by_title(request.data['title'])
        # if not found return error 404
        if event is None:
            return Response({"error": "No event with this id was found"}, status=status.HTTP_404_NOT_FOUND)
        # Serialize the found event
        serializer = EventSerializer(event, many=True)
        # return the Serialized event
        return Response(serializer.data, status=status.HTTP_200_OK)


## Coupon APIS
# Get the personalized coupons of a customer
class CouponGetView(APIView):
    serializer_class = CouponSerializer
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    @inject
    def __init__(self, coupon_service: CouponService):
        self.coupon_service = coupon_service

    def get(self, request):
        # Search for all coupons where the owner_id matches the provided ownerid
        coupon = self.coupon_service.get_coupons_by_owner(request.data['ownerID'])
        # if the customer doesn't have coupons return 404
        if coupon is None:
            return Response({"error": "No coupons found for this user"}, status=status.HTTP_404_NOT_FOUND)

        # Serialize the found coupon(s)
        serializer = CouponSerializer(coupon, many=True)
        # return the Serialized coupon(s)
        return Response(serializer.data, status=status.HTTP_200_OK)


# LogoutView handles the logout process by blacklisting the refresh token
class LogoutView(APIView):
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            #  Blacklist the refresh token
            token.blacklist()
            return Response({"message": "successfully logged out"}, status=status.HTTP_200_OK)
        except Exception as _:
            return Response({"error": "Invalid Token"}, status=status.HTTP_400_BAD_REQUEST)


# RegisterView allows new users to register
class RegisterView(APIView):

    @inject
    def __init__(self, user_service: UserService):
        self.user_service = user_service

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        email = request.data.get('email')
        firstname = request.data.get('firstname')
        lastname = request.data.get('lastname')

        # check if the username already exists
        if self.user_service.check_if_username_exists(username):
            return Response({"error": "Username already exists"}, status=status.HTTP_400_BAD_REQUEST)

        # Create a new user instance with hashed password
        with transaction.atomic():
            user = self.user_service.create_user(username, password, email, firstname, lastname)

        if user is None:
            return Response({"error": "User could´t be created"}, status=status.HTTP_409_CONFLICT)

        # if everything was successful return 201
        return Response({"message": "User registered successfully"}, status=status.HTTP_201_CREATED)


# TicketBookingView allows users to book tickets for events
class TicketBookingView(APIView):
    authentication_classes = [JWTAuthentication]
    # Only authenticated users can book tickets
    permission_classes = [IsAuthenticated]

    @inject
    def __init__(self, event_service: EventService, user_service: UserService, coupon_service: CouponService,
                 ticket_type_service: TicketTypService, ticket_service: TicketService):
        self.event_service = event_service
        self.user_service = user_service
        self.coupon_service = coupon_service
        self.ticket_type_service = ticket_type_service
        self.ticket_service = ticket_service

    def validate_request(self, data):
        # Validate required fields for booking
        required_fields = ['customerID', 'eventName', 'numberTickets', 'ticketTyp']
        missing_fields = [field for field in required_fields if not data.get(field)]

        # return error if a field is missing in the request
        if missing_fields:
            return {"error": f"Missing required fields: {', '.join(missing_fields)}"}

        try:
            # check if the tickets are a valid number
            # if the Numberticket not a number return error
            num_tickets = int(data.get('numberTickets'))
            if num_tickets <= 0:
                return {"error": "numberTickets must be a positive integer"}
        except ValueError:
            return {"error": "numberTickets must be an integer"}

        # if everything is correct return none
        return None

    def post(self, request):
        # validation of the input
        validation_error = self.validate_request(request.data)
        if validation_error:
            return Response(validation_error, status=status.HTTP_400_BAD_REQUEST)

        # accessing all elements of the body
        customer_id = request.data.get('customerID')
        event_title = request.data.get('eventName')
        num_tickets = int(request.data.get('numberTickets'))
        coupon_id = request.data.get('couponID')
        ticket_typ = request.data.get('ticketTyp')

        # get event
        event = self.event_service.get_event_by_title(event_title)
        if not event:
            return Response({"error": "No event with this name was found"}, status=status.HTTP_404_NOT_FOUND)

        # get user
        customer = self.user_service.get_user_by_id(customer_id)
        if not customer:
            return Response({"error": "No customer with this id was found"}, status=status.HTTP_404_NOT_FOUND)

        # get tickettyp
        tickettyp = self.ticket_type_service.get_ticket_type(ticket_typ)
        if not tickettyp:
            return Response({"error": "No ticket type with this name was found"}, status=status.HTTP_404_NOT_FOUND)

        # check if there is enough tickets
        if event.max_tickets - event.bought_tickets < num_tickets:
            return Response({"error": "Not enough tickets available"}, status=status.HTTP_409_CONFLICT)

        # coupon validation
        coupon_value = 0
        coupon = None
        # check if the customer used a coupon
        # validate if the user is the real one and the coupon is valid
        if coupon_id:
            coupon, coupon_error = self.coupon_service.get_coupon(coupon_id, customer_id)
            if coupon_error:
                # if the coupon was not valid or the rightful owner return 403
                return Response(coupon_error, status=status.HTTP_403_FORBIDDEN)
            # set value of the coupon
            coupon_value = coupon.amount

        # Create ticket and update event's bought tickets
        try:

            # Update event's bought tickets
            # before the ticket signal will be sent
            event.bought_tickets += num_tickets
            event.save()

            with transaction.atomic():
                self.ticket_service.create_ticket(customer, event, tickettyp, num_tickets, coupon_value, coupon)

        except Exception as e:
            return Response({"error": f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # return 201 when the ticket was successfully created/booked
        return Response({"message": "Tickets successfully booked"}, status=status.HTTP_201_CREATED)


### GET IDs

## get the ID of the user which the user with the username have
class GetUserIdView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    @inject
    def __init__(self, user_service: UserService):
        self.user_service = user_service

    def get(self, request):
        # get the user instance with the given parameter username
        user = self.user_service.get_user_by_username(request.data['username'])

        if user is not None:
            # return userid of the user/customer
            return Response({"user_id": user.id}, status=status.HTTP_200_OK)
        # return error when the username was not valid
        return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)


class GetEmployeePositionView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    @inject
    def __init__(self, user_service: UserService, employee_service: EmployeeService):
        self.user_service = user_service
        self.employee_service = employee_service

    def get(self, request):
        # Extract the user ID from the request body
        user_id = request.data.get('userid')

        # Validate if "userid" exists in the request
        if not user_id:
            return Response({"error": "userid is required in the request body"}, status=status.HTTP_400_BAD_REQUEST)

        # Get the user instance based on the provided ID
        user = self.user_service.get_user_by_id(user_id)
        if not user:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        # Check if the user is associated with an Employee
        employee = self.employee_service.get_employee_by_user(user)
        if not employee:
            return Response({"jobPosition": "NO"}, status=status.HTTP_200_OK)

        # If the user is an Employee, return their JobPosition
        return Response({"jobPosition": employee.position}, status=status.HTTP_200_OK)


## TicketType
# List all available ticket types
class TicketTypListView(APIView):
    # everyone can access this endpoint
    permission_classes = [AllowAny]

    @inject
    def __init__(self, ticket_type_service: TicketTypService):
        self.ticket_type_service = ticket_type_service

    def get(self, request):
        # get all the ticket types
        ticket_types = self.ticket_type_service.get_all_ticket_types()

        if ticket_types is None:
            return Response({"error": "An error occurred while fetching ticket types"},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # serialize all the ticket objects and return it
        serializer = TicketTypSerializer(ticket_types, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)
