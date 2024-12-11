from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
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

from backend.models import Event, Coupon, Employee


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
            return Response({"error": "No event with this id was found"},status=status.HTTP_404_NOT_FOUND)


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
            return Response({"error": "There were no coupons for this user"},status=status.HTTP_404_NOT_FOUND)

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
        User.objects.create(username=username,password=make_password(password),email=email,firstname=firstname,lastname=lastname)

        return Response({"message": "User registered successfully"}, status=status.HTTP_201_CREATED)


