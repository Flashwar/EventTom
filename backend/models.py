import uuid
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from django.db import models


class Customer(models.Model):
    firstname = models.CharField(max_length=100)
    lastname = models.CharField(max_length=100)
    email = models.EmailField(unique=True)


class Employee(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    class JobPosition(models.TextChoices):
        EVENTCREATOR = "EC", _("Eventcreator")
        EVENTMANGER = "EM", _("Eventmanager")

    position = models.CharField(max_length=2, choices=JobPosition.choices)
    # Berechtigungen

    def get_job_position(self) -> JobPosition:
        # Get value from choices enum
        return self.JobPosition(self.position)

class Event(models.Model):
    title = models.CharField(max_length=100, unique=True)
    max_tickets = models.IntegerField()
    bought_tickets = models.IntegerField(default=0, blank=True)
    threshold_tickets = models.IntegerField(default=0, blank=True)
    base_price = models.DecimalField(max_digits=10, decimal_places=2)
    creator = models.ForeignKey(
        'Employee',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        limit_choices_to={'position': 'EventCreator'}
    )
    created = models.DateTimeField(auto_now_add=True)

    def get_tickets(self):
        bought_tickets = self.tickets.filter(customer__isnull=False).count()
        return self.max_tickets - bought_tickets

class Coupon(models.Model):
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    owner = models.OneToOneField(Customer, on_delete=models.CASCADE, related_name='coupon')
    depleted = models.BooleanField(default=False)

class TicketTyp(models.Model):
    name = models.CharField(max_length=50)
    fee = models.DecimalField(max_digits=5, decimal_places=2)

class Ticket(models.Model):
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='tickets')
    owner = models.ForeignKey(Customer, on_delete=models.CASCADE, null=True, blank=True)
    ticket_typ = models.ForeignKey(TicketTyp, on_delete=models.SET_NULL, null=True)
    bought_time = models.DateTimeField(default=now)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.price:
            if self.ticket_typ:
                self.price = self.event.base_price * (1 + self.ticket_typ.fee / 100)
            else:
                self.price = self.event.base_price
        super().save(*args, **kwargs)





