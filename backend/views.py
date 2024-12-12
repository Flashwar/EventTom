from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from django.db import transaction
from rest_framework import status, permissions
from rest_framework.generics import  ListAPIView, RetrieveUpdateDestroyAPIView, \
    ListCreateAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.tokens import RefreshToken

from backend.Permissions import IsEventCreator
from backend.serializers import EventSerializer, CouponSerializer, EmployeeSerializer, CustomerSerializer

from backend.models import Event, Coupon, Employee, Ticket


class EventInfoView(APIView):
    serializer_class = EventSerializer
    permission_classes = [IsEventCreator]

    def create(self, request):
        serializer = EventSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class EventListView(ListAPIView):
    serializer_class = EventSerializer
    queryset = Event.objects.all()
    permission_classes = [AllowAny]


class EventDetailView(APIView):
    serializer_class = EventSerializer
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            event = Event.objects.filter(id=request.data['title'])
            serializer = EventSerializer(event, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Event.DoesNotExist:
            return Response({"error": "No event with this id was found"}, status=status.HTTP_404_NOT_FOUND)


## Coupon APIS

class CouponGetView(APIView):
    serializer_class = CouponSerializer
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request, ownerID):
        try:
            coupon = Coupon.objects.filter(owner_id=ownerID)
            serializer = CouponSerializer(coupon, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Coupon.DoesNotExist:
            return Response({"error": "There were no coupons for this user"}, status=status.HTTP_404_NOT_FOUND)


### TESTING COUPON APIS

# class CouponCreateView(CreateAPIView):
#     authentication_classes = [JWTAuthentication]
#     permission_classes = [IsAuthenticated]
#     queryset = Coupon.objects.all()
#     serializer_class = CouponSerializer
#
# class CouponUpdateView(UpdateAPIView):
#     authentication_classes = [JWTAuthentication]
#     permission_classes = [IsAuthenticated]
#     queryset = Coupon.objects.all()
#     serializer_class = CouponSerializer
#     lookup_field = 'id'


###  Customer TESTING APIS
# class CustomerCreateView(ListCreateAPIView):
#     authentication_classes = [JWTAuthentication]
#     permission_classes = [IsAuthenticated]
#     queryset = get_user_model().objects.all()
#     serializer_class = CustomerSerializer
#
# class CustomerDetailView(RetrieveUpdateDestroyAPIView):
#     authentication_classes = [JWTAuthentication]
#     permission_classes = [IsAuthenticated]
#     queryset = get_user_model().objects.all()
#     serializer_class = CustomerSerializer

###  EMPLOYEE TESTING APIS
# class EmployeeCreateView(CreateAPIView):
#     authentication_classes = [JWTAuthentication]
#     permission_classes = [IsAuthenticated]
#     queryset = Employee.objects.all()
#     serializer_class = EmployeeSerializer
#     permission_classes = [permissions.IsAuthenticated]


## Login

class LogoutView(APIView):
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({"message": "successfully logged out"}, status=status.HTTP_200_OK)
        except Exception as _:
            return Response({"error": "Invalid Token"}, status=status.HTTP_400_BAD_REQUEST)


class RegisterView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        email = request.data.get('email')
        firstname = request.data.get('firstname')
        lastname = request.data.get('lastname')

        if User.objects.filter(username=username).exists():
            return Response({"error": "Username already exists"}, status=status.HTTP_400_BAD_REQUEST)

        # Create a new user
        User.objects.create(username=username, password=make_password(password), email=email, firstname=firstname,
                            lastname=lastname)

        return Response({"message": "User registered successfully"}, status=status.HTTP_201_CREATED)


class TicketBookingView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def validate_request(self, data):

        # Validate request
        required_fields = ['customerID', 'eventName', 'numberTickets']
        missing_fields = [field for field in required_fields if not data.get(field)]

        if missing_fields:
            return {"error": f"Missing required fields: {', '.join(missing_fields)}"}

        try:
            num_tickets = int(data.get('numberTickets'))
            if num_tickets <= 0:
                return {"error": "numberTickets must be a positive integer"}
        except ValueError:
            return {"error": "numberTickets must be an integer"}

        return None

    def get_event(self, event_title):
        # Get the event based on the title
        try:
            return Event.objects.get(title=event_title)
        except Event.DoesNotExist:
            return None

    def get_coupon(self, coupon_id, customer_id):
        # Get the coupon if the user
        try:
            coupon = Coupon.objects.get(id=coupon_id)
            if coupon.owner != customer_id:
                return None, {"error": "The coupon isn't owned by the user"}
            return coupon, None
        except Coupon.DoesNotExist:
            return None, {"error": "Coupon not found"}

    def send_websocket_notifications(self, event, num_tickets):
        # send update/notification via websocket
        channel_layer = get_channel_layer()

        # Update for all user on the event site
        async_to_sync(channel_layer.group_send)(
            "SiteEvents",
            {
                "type": "update_ticket_count",
                "event": event.title,
                "bought_tickets": event.bought_tickets,
                "max_tickets": event.max_tickets,
            }
        )

        # Notifications for the EventManager
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

        # get event
        event = self.get_event(event_title)
        if not event:
            return Response({"error": "No event with this name was found"}, status=status.HTTP_404_NOT_FOUND)

        # check if there is enough tickets
        if event.max_tickets - event.bought_tickets < num_tickets:
            return Response({"error": "Not enough tickets available"}, status=status.HTTP_409_CONFLICT)

        # coupon validation
        coupon_value = 0
        coupon = None
        if coupon_id:
            coupon, coupon_error = self.get_coupon(coupon_id, customer_id)
            if coupon_error:
                return Response(coupon_error, status=status.HTTP_403_FORBIDDEN)
            coupon_value = coupon.amount

        # ticket buying
        try:
            with transaction.atomic():
                Ticket.objects.create(
                    event=event,
                    owner=customer_id,
                    price=(event.base_price * num_tickets) - coupon_value,
                )
                event.bought_tickets += num_tickets
                event.save()
        except Exception as e:
            return Response({"error": f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # WebSocket-Notification
        self.send_websocket_notifications(event, num_tickets)

        # delete coupon when not in debug mode
        if coupon and not settings.DEBUG:
            coupon.delete()

        return Response({"message": "Tickets successfully booked"}, status=status.HTTP_201_CREATED)
