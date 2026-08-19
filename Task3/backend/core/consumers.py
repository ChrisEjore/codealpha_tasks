import json
from channels.generic.websocket import AsyncWebsocketConsumer

class ProjectConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.project_id = self.scope['url_route']['kwargs']['project_id']
        self.room_group_name = f'project_{self.project_id}'

        # Join project room group
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        message_type = data.get('type')

        # Broadcast real-time actions (task moved or new comment added)
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'broadcast_update',
                'data': data
            }
        )

    async def broadcast_update(self, event):
        # Send data to connected WebSocket client
        await self.send(text_data=json.dumps(event['data']))