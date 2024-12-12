import uuid

from django.contrib.auth.models import User
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from django.db import models

class Employee(models.Model):
    staff_number = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    person = models.OneToOneField(User, on_delete=models.CASCADE)
    class JobPosition(models.TextChoices):
        EVENTCREATOR = "EC", _("Eventcreator")
        EVENTMANGER = "EM", _("Eventmanager")

    position = models.CharField(max_length=2, choices=JobPosition.choices)

class Event(models.Model):
    title = models.CharField(max_length=100, unique=True, primary_key=True)
    max_tickets = models.IntegerField()
    bought_tickets = models.IntegerField(default=0, blank=True)
    date = models.DateField(default=now, blank=True)
    threshold_tickets = models.IntegerField(default=0, blank=True)
    base_price = models.DecimalField(max_digits=10, decimal_places=2)
    created = models.DateTimeField(auto_now_add=True)


class Coupon(models.Model):
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    owner = models.OneToOneField(User, on_delete=models.CASCADE, related_name='coupon')
    depleted = models.BooleanField(default=False)

class TicketTyp(models.Model):
    name = models.CharField(max_length=50, primary_key=True)
    fee = models.DecimalField(max_digits=5, decimal_places=2)

class Ticket(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='tickets',blank=True, null=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    ticket_typ = models.ForeignKey(TicketTyp, on_delete=models.SET_NULL, null=True)
    bought_time = models.DateTimeField(default=now)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)






