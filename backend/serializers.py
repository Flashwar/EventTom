from django.contrib.auth import get_user_model
from rest_framework import serializers

from backend.models import Event, Coupon, Employee, TicketTyp, Ticket


# Serializer for the Evnet model
class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = '__all__'


# Serializer for the Coupon model
class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = Coupon
        fields = '__all__'


# Serializer for the Employee model
class EmployeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = '__all__'


# Serializer for the Customer(internal user model from Django)
class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = get_user_model()
        # these are the only fields needed from the user model
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'permissions']


# Serializer for the TicketTyp model
class TicketTypSerializer(serializers.ModelSerializer):
    class Meta:
        model = TicketTyp
        fields = '__all__'


# Serializer for the Ticket model
class TicketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ticket
        fields = '__all__'
