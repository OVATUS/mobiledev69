from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('openid/', include('oidc_provider.urls', namespace='oidc_provider')),
    path('api/', include('tasks.urls')),
]