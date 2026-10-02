from django.contrib.auth import login
from django.shortcuts import redirect, render
from django.utils.http import url_has_allowed_host_and_scheme

from .forms import RegisterForm


def register_view(request):
    # next = URL /openid/authorize?... ที่ต้องกลับไปต่อหลังสมัครเสร็จ
    next_url = request.POST.get('next') or request.GET.get('next', '')

    if request.method == 'POST':
        form = RegisterForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)  # สมัครเสร็จ = ล็อกอินให้เลย
            if next_url and url_has_allowed_host_and_scheme(
                next_url, allowed_hosts={request.get_host()}
            ):
                return redirect(next_url)  # กลับไปทำ OIDC flow ต่อ → กลับเข้าแอป
            return render(request, 'accounts/register_done.html', {'user': user})
    else:
        form = RegisterForm()

    return render(request, 'accounts/register.html', {'form': form, 'next': next_url})