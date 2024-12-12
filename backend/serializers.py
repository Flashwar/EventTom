from django.contrib.auth import get_user_model
from rest_framework import serializers
from backend.models import Event, Coupon, Employee, TicketTyp, Ticket


class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = '__all__'

class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = Coupon
        fields = '__all__'


class EmployeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = '__all__'

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = get_user_model()
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'permissions']

class TicketTypSerializer(serializers.ModelSerializer):
    class Meta:
        model = TicketTyp
        fields = '__all__'

class TicketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ticket
        fields = ['event', 'owner', 'ticket_typ', 'bought_time', 'price']