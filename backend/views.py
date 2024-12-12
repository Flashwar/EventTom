from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from django.db import transaction
from rest_framework import status, permissions
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, RetrieveUpdateDestroyAPIView, \
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

    def post(self, request):
        customer_id = request.data.get('customerID')
        event_name = request.data.get('eventName')
        num_tickets = request.data.get('numberTickets')
        coupon_id = request.data.get('couponID')

        # Validation of fields
        if not customer_id or not event_name or not num_tickets:
            return Response(
                {"error": "Missing required fields: customerID, eventName, and numberTickets"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            num_tickets = int(num_tickets)
            if num_tickets <= 0:
                return Response({"error": "numberTickets must be a positive integer"},
                                status=status.HTTP_400_BAD_REQUEST)
        except ValueError:
            return Response({"error": "numberTickets must be an integer"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # getting event
            event = Event.objects.get(title=event_name)
        except Event.DoesNotExist:
            return Response({"error": "No event with this name was found"}, status=status.HTTP_404_NOT_FOUND)

        # check if there is enough tickets
        if event.max_tickets - event.bought_tickets < num_tickets:
            return Response({"error": "Not enough tickets available"}, status=status.HTTP_409_CONFLICT)

        # coupon accessing and setting the value
        coupon_value = 0
        if coupon_id:
            try:
                coupon = Coupon.objects.get(id=coupon_id)
                if coupon.owner != customer_id:
                    return Response({"error": "The coupon isn't owned by the user"},
                                    status=status.HTTP_403_FORBIDDEN)
                coupon_value = coupon.amount
            except Coupon.DoesNotExist:
                return Response({"error": "Coupon not found"}, status=status.HTTP_404_NOT_FOUND)
        try:
            with transaction.atomic():
                Ticket.objects.create(
                    event=event,
                    owner=customer_id,
                    price=(event.base_price * num_tickets) - coupon_value,
                )
                # Update of the bought tickets
                event.bought_tickets += num_tickets
                event.save()
        except Exception as e:
            return Response({"error": f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # messaging all user on the website via websocket

        # update ticket count
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            "SiteEvents",
            {
                "type": "update_ticket_count",
                "event_id": event.title,
                "bought_tickets": event.bought_tickets,
                "max_tickets": event.max_tickets,            }
        )
        # update Admins
        async_to_sync(channel_layer.group_send)(
            "BuyingNotificationAdmin",
            {
                "type": "send_notification",
                "message": f"{num_tickets} Tickets for {event.title} have been booked!",
            }
        )

        return Response({"message": "Tickets successfully booked"}, status=status.HTTP_201_CREATED)
