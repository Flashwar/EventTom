from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.conf import settings
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from django.db import transaction
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.tokens import RefreshToken

from backend.models import Event, Coupon, Employee, Ticket, TicketTyp
from backend.permissions import IsEventCreator
from backend.serializers import EventSerializer, CouponSerializer, TicketTypSerializer

# EventInfoView allows creating a new event
class EventInfoView(APIView):
    serializer_class = EventSerializer
    # Only EventCreator are allowed to create an event
    permission_classes = [IsEventCreator]

    def post(self, request):
        serializer = EventSerializer(data=request.data)
        # Validate incoming data and create an event
        if serializer.is_valid():
            event = serializer.save()

            # send update/notification via websocket to all users on the event site
            channel_layer = get_channel_layer()

            async_to_sync(channel_layer.group_send)(
                "SiteEvents",
                {
                    "type": "update_ticket_count",
                    "event_title": event.title,
                    "bought_tickets": event.bought_tickets,
                    "max_tickets": event.max_tickets,
                }
            )
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Listing all Events
class EventListView(ListAPIView):
    serializer_class = EventSerializer
    # Get all event objects
    queryset = Event.objects.all()
    # Everyone can call this API
    permission_classes = [AllowAny]

# EventDetailView retrieves a specific event based on its title
class EventDetailView(APIView):
    serializer_class = EventSerializer
    authentication_classes = [JWTAuthentication]
    # Only authenticated users can access this
    # TODO Maybe this needs to be changed
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # Search for an event with the given title
            event = Event.objects.filter(title=request.data['title'])
            # Serialize the found event
            serializer = EventSerializer(event, many=True)
            # return the Serialized event
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Event.DoesNotExist:
            # if there was no event with this title return 404
            return Response({"error": "No event with this id was found"}, status=status.HTTP_404_NOT_FOUND)


## Coupon APIS
# Get the personalized coupons of a customer
class CouponGetView(APIView):
    serializer_class = CouponSerializer
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # Search for all coupons where the owner_id matches the provided ownerid
            coupon = Coupon.objects.filter(owner_id=request.data['ownerID'])
            # Serialize the found coupon(s)
            serializer = CouponSerializer(coupon, many=True)
            # return the Serialized coupon(s)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Coupon.DoesNotExist:
            # if the customer doesn't have coupons return 404
            return Response({"error": "There were no coupons for this user"}, status=status.HTTP_404_NOT_FOUND)



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
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        email = request.data.get('email')
        firstname = request.data.get('firstname')
        lastname = request.data.get('lastname')

        # check if the username already exists
        if User.objects.filter(username=username).exists():
            return Response({"error": "Username already exists"}, status=status.HTTP_400_BAD_REQUEST)

        # Create a new user instance with hashed password
        User.objects.create(username=username, password=make_password(password), email=email, firstname=firstname,
                            lastname=lastname)

        # if everything was successful return 201
        return Response({"message": "User registered successfully"}, status=status.HTTP_201_CREATED)

# TicketBookingView allows users to book tickets for events
class TicketBookingView(APIView):
    authentication_classes = [JWTAuthentication]
    # Only authenticated users can book tickets
    permission_classes = [IsAuthenticated]

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

    def get_event(self, event_title):
        # Get the event based on the title
        try:
            return Event.objects.get(title=event_title)
        except Event.DoesNotExist:
            # return none if the event doesn't exist
            return None

    def get_coupon(self, coupon_id, customer_id):
        # Get the coupon of the user
        try:
            # get the used coupon
            coupon = Coupon.objects.get(id=coupon_id)
            # check if the owner of the coupon is the customer who is buying tickets rn
            if str(coupon.owner) != str(self.get_user(customer_id).username):
                # return error if the user is not the right one
                return None, {"error": "The coupon isn't owned by the user"}
            # if valid and the rightful owner, return coupon and no error -> none
            return coupon, None
        except Coupon.DoesNotExist:
            # if the ticket is not valid return error
            return None, {"error": "Coupon not found"}

    # Get the tickettyp instance with ticket name
    def get_tickettyp(self, tickettypname):
        try:
            return TicketTyp.objects.get(name=tickettypname)
        except TicketTyp.DoesNotExist:
            return None

    # Get the coupon of the user
    def get_user(self, ownerid):
        try:
            return User.objects.get(id=ownerid)
        except User.DoesNotExist:
            return None

    # send update/notification via websocket
    def send_websocket_notifications(self, event, num_tickets):
        channel_layer = get_channel_layer()

        # Send a notification to the  all user on the event site
        async_to_sync(channel_layer.group_send)(
            "SiteEvents",
            {
                "type": "update_ticket_count",
                "event_title": event.title,
                "bought_tickets": event.bought_tickets,
                "max_tickets": event.max_tickets,
            }
        )

        # Send a notification to the EventManager WebSocket group
        async_to_sync(channel_layer.group_send)(
            "BuyingNotificationAdmin",
            {
                "type": "send_notification",
                "message": f"{num_tickets} Tickets for {event.title} have been booked!",
            }
        )

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
        events = self.get_event(event_title)
        if not events:
            return Response({"error": "No event with this name was found"}, status=status.HTTP_404_NOT_FOUND)

        # get user
        customers = self.get_user(customer_id)
        if not customers:
            return Response({"error": "No customer with this id was found"}, status=status.HTTP_404_NOT_FOUND)

        # get tickettyp
        tickettyp = self.get_tickettyp(ticket_typ)
        if not tickettyp:
            return Response({"error": "No ticket type with this name was found"}, status=status.HTTP_404_NOT_FOUND)

        # check if there is enough tickets
        if events.max_tickets - events.bought_tickets < num_tickets:
            return Response({"error": "Not enough tickets available"}, status=status.HTTP_409_CONFLICT)

        # coupon validation
        coupon_value = 0
        coupon = None
        # check if the customer used a coupon
        # validate if the user is the real one and the coupon is valid
        if coupon_id:
            coupon, coupon_error = self.get_coupon(coupon_id, customer_id)
            if coupon_error:
                # if the coupon was not valid or the rightful owner return 403
                return Response(coupon_error, status=status.HTTP_403_FORBIDDEN)
            # set value of the coupon
            coupon_value = coupon.amount

        # Create ticket and update event's bought tickets
        try:
            with transaction.atomic():
                Ticket.objects.create(
                    owner=customers,
                    ticket_typ=tickettyp,
                    event=events,
                    numb_tickets=num_tickets,
                    price=((events.base_price + (events.base_price * tickettyp.fee)) * num_tickets) - coupon_value
                )

                # Update event's bought tickets
                events.bought_tickets += num_tickets
                events.save()

        except Exception as e:
            return Response({"error": f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Send WebSocket notifications
        self.send_websocket_notifications(events, num_tickets)

        # delete coupon when not in debug mode
        if coupon and not settings.DEBUG:
            coupon.delete()

        # return 201 when the ticket was successfully created/booked
        return Response({"message": "Tickets successfully booked"}, status=status.HTTP_201_CREATED)


### GET IDs

## get the ID of the user which the user with the username have
class GetUserIdView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # get the user instance with the given parameter username
            user = User.objects.get(username=request.data['username'])
            # return userid of the user/customer
            return Response({"user_id": user.id}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            # return error when the username was not valid
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

# Get user ID by employee's staff number (UUID)
class GetUserIdFromEmployeeUUID(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # get employee with the staff_number
            employee = Employee.objects.get(staff_number=request.data['staff_number'])

            # get the user from the employee
            user = employee.person
            # return employee id
            return Response({"user_id": user.id}, status=status.HTTP_200_OK)
        except Employee.DoesNotExist:
            return Response({"error": "Employee not found for the given UUID"}, status=status.HTTP_404_NOT_FOUND)


## TicketType
# List all available ticket types
class TicketTypListView(ListAPIView):
    serializer_class = TicketTypSerializer
    queryset = TicketTyp.objects.all()
    permission_classes = [AllowAny]
