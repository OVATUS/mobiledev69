from oidc_provider.models import Token
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import api_view
from rest_framework.response import Response

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


@api_view(['POST'])
def logout_view(request):
    """ลบ Access Token ตัวที่ใช้เรียกอยู่ออกจากฐานข้อมูล (token ใช้ต่อไม่ได้อีก)"""
    if isinstance(request.auth, Token):
        request.auth.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)