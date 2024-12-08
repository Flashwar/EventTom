from django.contrib.auth import get_user_model
from django.shortcuts import render
from rest_framework import viewsets, status, permissions
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, RetrieveUpdateDestroyAPIView, \
    ListCreateAPIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from backend.serializers import EventSerializer, CouponSerializer, EmployeeSerializer, CustomerSerializer

from backend.models import Event, Coupon, Employee


def WebsocketTestView(request):
    return render(request, 'Test.html')


class EventInfoView(APIView):
    serializer_class = EventSerializer

    def create(self, request):
        # @TODO: Allow only EventManger to use this API Endpoint
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

    def get(self, request, ownerID):
        try:
            coupon = Coupon.objects.filter(owner_id=ownerID)
            serializer = CouponSerializer(coupon, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Coupon.DoesNotExist:
            return Response({"error": "There were no coupons for this user"},status=status.HTTP_404_NOT_FOUND)

### TESTING COUPON APIS

class CouponCreateView(CreateAPIView):
    queryset = Coupon.objects.all()
    serializer_class = CouponSerializer

class CouponUpdateView(UpdateAPIView):
    queryset = Coupon.objects.all()
    serializer_class = CouponSerializer
    lookup_field = 'id'


###  Customer TESTING APIS
class CustomerCreateView(ListCreateAPIView):
    queryset = get_user_model().objects.all()
    serializer_class = CustomerSerializer

class CustomerDetailView(RetrieveUpdateDestroyAPIView):
    queryset = get_user_model().objects.all()
    serializer_class = CustomerSerializer

###  EMPLOYEE TESTING APIS
class EmployeeCreateView(CreateAPIView):
    queryset = Employee.objects.all()
    serializer_class = EmployeeSerializer
    permission_classes = [permissions.IsAuthenticated]



