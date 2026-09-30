import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from django.core.management import call_command
from oidc_provider.models import Client, ResponseType, RSAKey

# 1. ตรวจสอบและสร้าง RSA Key (จำเป็นสำหรับ RS256 JWT Token)
if not RSAKey.objects.exists():
    print("Generating RSA key for OIDC provider...")
    call_command('creatersakey')
else:
    print("RSA key already exists.")

# 2. สร้างผู้ใช้สำหรับทดสอบ (Demo Account)
username = 'student01'
password = 'test1234'
user, user_created = User.objects.get_or_create(username=username)
if user_created:
    user.set_password(password)
    user.is_staff = True
    user.save()
    print(f"Created demo user: {username} / {password}")
else:
    print(f"Demo user '{username}' already exists.")

# 3. สร้าง OIDC Client สำหรับ Flutter Web (Authorization Code Flow)
client_id = 'flutter-task-app'
client_name = 'Flutter Task Client'
redirect_uri = 'http://localhost:50000/'

client, created = Client.objects.get_or_create(
    client_id=client_id,
    defaults={
        'name': client_name,
        'client_type': 'public',
        'jwt_alg': 'RS256',
        'require_consent': False,
        'reuse_consent': True,
    }
)

# กำหนด Redirect URIs (เป็น property list)
client.redirect_uris = [redirect_uri]
client.post_logout_redirect_uris = [redirect_uri]
client.save()

# เพิ่ม Response Type 'code' (Authorization Code Flow)
code_response_type = ResponseType.objects.filter(value='code').first()
if code_response_type:
    client.response_types.add(code_response_type)

if created:
    print(f"Created OIDC Client: {client_id}")
else:
    print(f"OIDC Client '{client_id}' is ready.")