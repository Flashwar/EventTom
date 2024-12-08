import json
from channels.generic.websocket import AsyncJsonWebsocketConsumer

class AdminNotificationConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        self.group_name = "BuyingNotificationAdmin"
        await self.channel_layer.group_add(self.group_name, self.channel_name)

        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    # Receive  be ignored, because the channel direction is only unidirectional
    # Backend -> Frontend

    async def send_message(self, event):
        message = event['message']
        await self.send(text_data=json.dumps({'message': message}))