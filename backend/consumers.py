import json
from channels.generic.websocket import AsyncJsonWebsocketConsumer

# WebSocket for sending notification to the currently logged in Eventmanager
class AdminNotificationConsumer(AsyncJsonWebsocketConsumer):

    # Connecting to the WebSocket
    async def connect(self):
        self.group_name = "BuyingNotificationAdmin"
        await self.channel_layer.group_add(self.group_name, self.channel_name)

        await self.accept()

    # Disconnecting from the WebSocket
    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    # Send a notification to the WebSocket group
    async def send_notification(self, event):
        await self.send(text_data=json.dumps({'message': event['message']}))

# WebSocket for notifying active Customers/Employees on the event list page
class EventConsumer(AsyncJsonWebsocketConsumer):

    # Connecting to the WebSocket
    async def connect(self):
        self.group_name = "SiteEvents"
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        await self.accept()

        # TODO DELETE
        # events = list(Event.objects.all().order_by('-created_at').values())
        # await self.send(text_data=json.dumps({"type": "initial_data", "events": events}))

    # Disconnecting from the WebSocket
    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.group_name,
            self.channel_name
        )

    # Send an update about a new created event
    async def send_event(self, event):
        await self.send(text_data=json.dumps({
            "type": "new_event",
            "message": {
                "title": event["event_title"],
                "bought_tickets": event["bought_tickets"],
                "max_tickets": event["max_tickets"],
                "base_price": event["base_price"],
                "ticket_typ": event["ticket_typ"],
            }
        }))

    # Send update about decreased available tickets for the event
    async def update_ticket_count(self, event):
        await self.send(text_data=json.dumps({
            "type": "update_ticket_count",
            "message": {
                "title": event["event_title"],
                "bought_tickets": event["bought_tickets"],
                "max_tickets": event["max_tickets"]
            }
        }))
