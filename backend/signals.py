from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import Event, Ticket


# Send a notification to all users on the event's list page
@receiver(post_save, sender=Event)
def notify_event_creation_or_update(sender, instance, created, **kwargs):
    channel_layer = get_channel_layer()
    print("sending event creation signal")
    if created:
        # a new event was created
        # send update/notification via websocket to all users on the event site
        async_to_sync(channel_layer.group_send)(
            "SiteEvents",
            {
                "type": "new_event",
                "title": instance.title,
                "bought_tickets": instance.bought_tickets,
                "max_tickets": instance.max_tickets,
                "base_price": float(instance.base_price),
                "threshold_tickets": instance.threshold_tickets,
            },
        )


# Notify EventManager that X ticket were brought for event Y
# and also send an update about the decreased ticket count
@receiver(post_save, sender=Ticket)
def notify_ticket_creation(sender, instance, created, **kwargs):
    if created:
        event = instance.event
        channel_layer = get_channel_layer()

        # Send an update about the decreased ticket count
        async_to_sync(channel_layer.group_send)(
            "SiteEvents",
            {
                "type": "update_ticket_count",
                "title": event.title,
                "bought_tickets": event.bought_tickets,
                "max_tickets": event.max_tickets,
            }
        )

    # Send a notification to the EventManager WebSocket group
    async_to_sync(channel_layer.group_send)(
        "BuyingNotificationAdmin",
        {
            "type": "send_notification",
            "message": f"{event.title}: Es wurden {instance.numb_tickets} Tickets gekauft",
        },
    )
