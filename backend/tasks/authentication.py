from django.utils import timezone
from rest_framework.authentication import BaseAuthentication, get_authorization_header
from rest_framework.exceptions import AuthenticationFailed
from oidc_provider.models import Token


class OIDCBearerTokenAuthentication(BaseAuthentication):
    """ตรวจสอบ Bearer Access Token ที่ออกโดย django-oidc-provider"""
    keyword = 'Bearer'

    def authenticate(self, request):
        auth = get_authorization_header(request).split()

        if not auth or auth[0].lower() != self.keyword.lower().encode():
            return None

        if len(auth) == 1:
            raise AuthenticationFailed('Invalid token header. No credentials provided.')
        elif len(auth) > 2:
            raise AuthenticationFailed('Invalid token header. Token string should not contain spaces.')

        try:
            token_string = auth[1].decode()
        except UnicodeError:
            raise AuthenticationFailed('Invalid token header. Token string contains invalid characters.')

        try:
            token = Token.objects.select_related('user').get(access_token=token_string)
        except Token.DoesNotExist:
            raise AuthenticationFailed('Invalid or expired token.')

        # ตรวจสอบการหมดอายุของ Token
        is_expired = token.has_expired if isinstance(token.has_expired, bool) else token.has_expired()
        if is_expired or (token.expires_at and timezone.now() >= token.expires_at):
            raise AuthenticationFailed('Token has expired.')

        if not token.user.is_active:
            raise AuthenticationFailed('User is inactive or deleted.')

        return (token.user, token)

    def authenticate_header(self, request):
        return self.keyword