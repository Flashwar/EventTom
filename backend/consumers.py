import json

from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.layers import get_channel_layer
from django.http import JsonResponse
from keyring.backends.libsecret import available

from backend.models import Event


class AdminNotificationConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        self.group_name = "BuyingNotificationAdmin"
        await self.channel_layer.group_add(self.group_name, self.channel_name)

        await self.accept()

    async def disconnect(self, close_code):
         await self.channel_layer.group_discard(self.group_name, self.channel_name)

    # Receive be ignored, because the channel direction is only unidirectional
    # Backend -> Frontend
    # async def receive(self, text_data):
    #
    #     text_data_json = json.loads(text_data)
    #     print(text_data_json)
    #
    #     channel_layer = get_channel_layer()
    #
    #     await channel_layer.group_send(
    #         "BuyingNotificationAdmin",
    #         {
    #             "type": "send_notification",
    #             "message": {"text": f"{text_data_json} Tickets wurden gekauft."}
    #         }
    #     )

    async def send_notification(self, event):
        message = event['message']
        await self.send(text_data=json.dumps({'message': message}))


class EventConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        self.group_name = "SiteEvents"
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        await self.accept()

        #events = list(Event.objects.all().order_by('-created_at').values())
        #await self.send(text_data=json.dumps({"type": "initial_data", "events": events}))

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.group_name,
            self.channel_name
        )

    async def send_event(self, event):
        await self.send(text_data=json.dumps({"type": "new_event", "event": event["message"]}))


    async def update_ticket_count(self, event):

        await self.send(text_data=json.dumps({
            "type": "update_ticket_count",
            "event_id": event["title"],
            "bought_tickets": event["bought_tickets"],
            "max_tickets": event["max_tickets"]
        }))