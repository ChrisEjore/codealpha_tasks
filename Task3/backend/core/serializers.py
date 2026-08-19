from rest_framework import serializers
from .models import Board, Task, Comment
from django.contrib.auth.models import User

class CommentSerializer(serializers.ModelSerializer):
    author_name = serializers.ReadOnlyField(source='author.username')

    class Meta:
        model = Comment
        fields = ['id', 'task', 'author', 'author_name', 'content', 'created_at']

class TaskSerializer(serializers.ModelSerializer):
    comments = CommentSerializer(many=True, read_only=True)
    assigned_to_name = serializers.ReadOnlyField(source='assigned_to.username')

    class Meta:
        model = Task
        fields = ['id', 'board', 'title', 'description', 'assigned_to', 'assigned_to_name', 'status', 'due_date', 'comments']

class BoardSerializer(serializers.ModelSerializer):
    tasks = TaskSerializer(many=True, read_only=True)

    class Meta:
        model = Board
        fields = ['id', 'name', 'members', 'tasks', 'created_at']