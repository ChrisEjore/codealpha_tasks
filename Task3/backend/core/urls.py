from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BoardViewSet, TaskViewSet, CommentViewSet

router = DefaultRouter()
router.register(r'boards', BoardViewSet)
router.register(r'tasks', TaskViewSet)
router.register(r'comments', CommentViewSet)

urlpatterns = [
    path('', include(router.urls)),
]