from rest_framework import viewsets, permissions
from .models import Task
from .serializers import TaskSerializer

class TaskViewSet(viewsets.ModelViewSet):
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # ผู้ใช้จะเห็นเฉพาะ Task ของตนเองเท่านั้น
        return Task.objects.filter(user=self.request.user).order_by('-created_at')

    def perform_create(self, serializer):
        # บันทึก User ปัจจุบันเป็นเจ้าของ Task โดยอัตโนมัติ
        serializer.save(user=self.request.user)