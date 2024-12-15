import uuid

from django.contrib.auth.models import User
from django.db import models
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _


class Employee(models.Model):
    # Unique identifier for each employee, generated automatically
    staff_number = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Link to the user model -> one employee is one customer under the hood
    person = models.OneToOneField(User, on_delete=models.CASCADE)

    class JobPosition(models.TextChoices):
        EVENTCREATOR = "EC", _("Eventcreator")
        EVENTMANGER = "EM", _("Eventmanager")

    # Job position of the employee, restricted to Eventmanager and Eventcreator
    position = models.CharField(max_length=2, choices=JobPosition.choices)


class Event(models.Model):
    # Unique identifier for each event
    title = models.CharField(max_length=100, unique=True, primary_key=True)

    # Maximal number of tickets available to buy
    max_tickets = models.IntegerField()

    # Current number of bought tickets
    bought_tickets = models.IntegerField(default=0, blank=True)

    # Date and time of the event, default is the current date and time of the creation
    # it is a little addition to the given requirements
    date = models.DateTimeField(default=now, blank=True)

    # The minimum number of tickets required for the event
    threshold_tickets = models.IntegerField(default=0, blank=True)

    # Price of the event location etc.
    base_price = models.DecimalField(max_digits=10, decimal_places=2)

    # Date and time of the creation of the event
    created = models.DateTimeField(auto_now_add=True)


class Coupon(models.Model):
    # how much money does the coupon hold
    amount = models.DecimalField(max_digits=10, decimal_places=2)

    # Link to the owner of the personalized coupon
    owner = models.OneToOneField(User, on_delete=models.CASCADE, related_name='coupon')

    # Status is the ticket was already been emptied
    depleted = models.BooleanField(default=False)


class TicketTyp(models.Model):
    # Unique name of the Tickettyp, e.g.: luxus, premium
    name = models.CharField(max_length=50, primary_key=True)

    # The fee for the ticket, represented as a floating point value of the ticket price
    fee = models.DecimalField(max_digits=5, decimal_places=2)


class Ticket(models.Model):
    # Link to the Title of the Event
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='tickets', blank=True, null=True)

    # Link to the owner of the ticket
    owner = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)

    # Link to the tickettyp
    ticket_typ = models.ForeignKey(TicketTyp, on_delete=models.SET_NULL, null=True)

    # time and date of the purchase
    bought_time = models.DateTimeField(default=now)

    # price of the ticket ( base_price + (base_price*fee)) * number_ticket
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    # number of tickets bought
    # @TODO Add
    # numb_tickets = models.IntegerField(default=0)
