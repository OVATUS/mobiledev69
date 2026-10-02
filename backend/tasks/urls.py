from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import TaskViewSet, logout_view

router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')

urlpatterns = [
    path('logout/', logout_view, name='api-logout'),
] + router.urls