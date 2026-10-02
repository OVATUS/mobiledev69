from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User


# Django แปลข้อความเรื่องรหัสผ่านเป็นไทยไม่ครบ เลยกำหนดเองตาม error code
THAI_PASSWORD_ERRORS = {
    'password_mismatch': 'รหัสผ่านทั้งสองช่องไม่ตรงกัน',
    'password_too_short': 'รหัสผ่านสั้นเกินไป ต้องมีอย่างน้อย 8 ตัว',
    'password_too_common': 'รหัสผ่านนี้ง่ายเกินไป',
    'password_entirely_numeric': 'รหัสผ่านต้องไม่เป็นตัวเลขล้วน',
    'password_too_similar': 'รหัสผ่านคล้ายกับชื่อผู้ใช้หรืออีเมลมากเกินไป',
}


class RegisterForm(UserCreationForm):
    first_name = forms.CharField(label='ชื่อ', max_length=150)
    last_name = forms.CharField(label='นามสกุล', max_length=150, required=False)
    email = forms.EmailField(label='อีเมล')

    class Meta:
        model = User
        fields = ('username', 'first_name', 'last_name', 'email')
        labels = {'username': 'ชื่อผู้ใช้'}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['username'].help_text = 'ภาษาอังกฤษ ตัวเลข หรือ @ . + - _ ไม่เกิน 150 ตัว'
        self.fields['password1'].label = 'รหัสผ่าน'
        self.fields['password1'].help_text = 'อย่างน้อย 8 ตัว และไม่ใช่ตัวเลขล้วน'
        self.fields['password2'].label = 'ยืนยันรหัสผ่าน'
        self.fields['password2'].help_text = ''

    def add_error(self, field, error):
        if isinstance(error, forms.ValidationError) and hasattr(error, 'error_list'):
            error = forms.ValidationError([
                forms.ValidationError(THAI_PASSWORD_ERRORS.get(e.code, e.messages[0]), code=e.code)
                for e in error.error_list
            ])
        super().add_error(field, error)

    def clean_email(self):
        email = self.cleaned_data['email'].lower()
        if User.objects.filter(email__iexact=email).exists():
            raise forms.ValidationError('อีเมลนี้ถูกใช้สมัครไปแล้ว')
        return email