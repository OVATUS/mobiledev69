def userinfo(claims, user):
    """กำหนดข้อมูลผู้ใช้ที่ /openid/userinfo จะส่งกลับไปให้แอป

    django-oidc-provider จะกรอง claims ตาม scope ที่แอปขอให้อัตโนมัติ
    (profile -> name, preferred_username / email -> email)
    """
    claims['name'] = user.get_full_name() or user.username
    claims['given_name'] = user.first_name
    claims['family_name'] = user.last_name
    claims['preferred_username'] = user.username
    claims['email'] = user.email
    return claims