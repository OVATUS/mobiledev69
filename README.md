# ✅ Daily Task Tracker — แอปจัดการงานประจำวัน

แอป Flutter สำหรับนักศึกษาและคนทำงานที่อยากจดงานที่ต้องทำในแต่ละวัน แยกตามหมวดหมู่ (งาน / ส่วนตัว / การเรียน) กำหนดความสำคัญและวันส่งได้ เข้าสู่ระบบอย่างปลอดภัยผ่าน **OpenID Connect** (django-oidc-provider) แต่ละคนเห็นเฉพาะงานของตัวเอง

ผู้พัฒนา: นนทพันธ์ บุญตระการ (66114540346)

## ✨ Features

**ฟีเจอร์หลัก**
- 📝 สมัครสมาชิก (Register) บนหน้า OIDC Server แล้วกลับเข้าแอปอัตโนมัติ — แอปไม่แตะรหัสผ่านเลย
- 🔐 Login / Logout ผ่าน OIDC (Authorization Code Flow + PKCE) — ปิดเปิดแอปใหม่ยังล็อกอินอยู่, Logout ล้าง token ทั้งในเครื่องและที่ server
- 🛡️ Route Guard (go_router) — ทุกหน้าเข้าได้หลังล็อกอินเท่านั้น, token หมดอายุจะพากลับหน้า Login อัตโนมัติ
- ➕ Create — เพิ่มงานผ่านฟอร์ม พร้อม validation
- 📋 Read — รายการงาน (List) และหน้ารายละเอียด (Detail)
- ✏️ Update / 🗑️ Delete — แก้ไข, ติ๊กเสร็จ, ลบงาน (มีหน้ายืนยัน)
- ⚠️ Error Handling — แจ้งเตือนภาษาไทยด้วย SnackBar / หน้าลองใหม่ เมื่อเน็ตหลุดหรือ backend ปิด

**Extra Features**
- 🌙 Dark Mode สลับได้ และจดจำค่าไว้ (รีเฟรชแล้วไม่หาย)
- 🔍 ค้นหาแบบเรียลไทม์ + กรองตามหมวดหมู่ + กรองตามสถานะ + เรียงลำดับ (ใหม่สุด / กำหนดส่ง / ความสำคัญ)
- 📊 สรุปจำนวนงาน ทั้งหมด / รอดำเนินการ / เสร็จแล้ว

## 🧰 Tech Stack

- Flutter (Dart SDK ≥ 3.12) — MVVM, provider, go_router, dio, flutter_secure_storage, openid_client
- Python 3.14 + Django 6.1 + Django REST Framework
- django-oidc-provider 0.9 (OIDC Server)
- uv (จัดการ Python และ dependencies)

## 📦 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [uv](https://docs.astral.sh/uv/getting-started/installation/) (uv จะดาวน์โหลด Python 3.14 ให้อัตโนมัติ)
- [Google Chrome](https://www.google.com/chrome/)
- [Git](https://git-scm.com/downloads)

## ▶️ How to Run

```bash
git clone -b project https://github.com/OVATUS/mobiledev69.git
cd mobiledev69
```

**Terminal 1 — Backend (OIDC Server, port 8000)**

```bash
cd backend
uv sync
uv run manage.py migrate
uv run setup_demo.py
uv run manage.py runserver
```

> `setup_demo.py` จะสร้าง RSA key (creatersakey), demo account และ OIDC client ให้อัตโนมัติ รันซ้ำได้

**Terminal 2 — Flutter Web App (port 50000)**

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 50000
```

> ⚠️ ต้องใช้ port **50000** เท่านั้น เพราะลงทะเบียน redirect URI ไว้ที่ `http://localhost:50000/`

## 👤 Demo Account

| Username | Password |
|---|---|
| `student01` | `test1234` |

## 🖼️ Screenshots

| หน้า Login | หน้ารายการงาน |
|---|---|
| ![Login](docs/screenshots/login.png) | ![Task list](docs/screenshots/task_list.png) |

## 🎬 Demo Video

[▶️ ดูวิดีโอสาธิตบน YouTube](https://youtu.be/YOUR_VIDEO_ID)