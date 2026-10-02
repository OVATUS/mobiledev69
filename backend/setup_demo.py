"""สคริปต์เตรียมข้อมูลเริ่มต้น: RSA key + demo user + OIDC client

รันซ้ำได้หลายครั้งโดยไม่พัง:  uv run setup_demo.py
"""
import os

import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User  # noqa: E402
from django.core.management import call_command  # noqa: E402
from oidc_provider.models import Client, ResponseType, RSAKey  # noqa: E402

# ต้องตรงกับ AppConstants.oidcRedirectUri ในแอป และ --web-port ใน README
REDIRECT_URI = 'http://localhost:50000/'

# 1. RSA Key สำหรับเซ็น ID Token (RS256)
if not RSAKey.objects.exists():
    print('Generating RSA key for OIDC provider...')
    call_command('creatersakey')
else:
    print('RSA key already exists.')

# 2. Demo Account (ตั้งรหัสผ่านใหม่ทุกครั้ง เพื่อให้ตรงกับ README เสมอ)
username, password = 'student01', 'test1234'
user, _ = User.objects.get_or_create(username=username)
user.set_password(password)
user.first_name = 'Student'
user.last_name = 'Demo'
user.email = 'student01@example.com'
user.is_staff = True  # เข้า /admin/ ได้ด้วย (ไว้ดูข้อมูลตอนทดสอบ)
user.save()
print(f'Demo user ready: {username} / {password}')

# 3. OIDC Client แบบ public (ไม่มี secret) ใช้ Authorization Code + PKCE
client, created = Client.objects.get_or_create(
    client_id='flutter-task-app',
    defaults={'name': 'Flutter Task Client'},
)
client.client_type = 'public'
client.jwt_alg = 'RS256'
client.require_consent = True   # ให้เห็นหน้า Consent ตาม storyboard
client.reuse_consent = True     # กดยอมรับครั้งเดียวพอ
client.redirect_uris = [REDIRECT_URI]
client.post_logout_redirect_uris = [REDIRECT_URI]
client.save()

# อนุญาตเฉพาะ Authorization Code Flow
client.response_types.set(ResponseType.objects.filter(value='code'))

print(f"OIDC client '{client.client_id}' {'created' if created else 'updated'}.")