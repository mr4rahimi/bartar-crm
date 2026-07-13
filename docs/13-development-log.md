# Development Log

وضعیت پیاده‌سازی پروژه. بعد از هر فیچر به‌روزرسانی می‌شود.

---

## ✅ انجام‌شده

### Infrastructure
- Prisma Schema کامل فاز ۱ (۲۱ جدول) + Migration اولیه + Seed (۳۸ Permission، ۷ Role پیش‌فرض، Bootstrap Admin)
- Docker PostgreSQL (پورت 5438) — در DATABASE_URL از 127.0.0.1 استفاده شود نه localhost
- shared/lib: prisma singleton, cn, api-response, errors (AppError), handle-api-error, request-context
- shared/validators: pagination.schema

### Feature: Authentication (کامل)
- Session-Based Auth با کوکی HttpOnly + Sliding Expiration (تمدید ۳۰روزه در آستانه‌ی ۱۵ روز)
- API: POST /api/v1/auth/login | POST /api/v1/auth/logout | GET /api/v1/auth/me
- Middleware (چک وجود کوکی + redirect) — اعتبارسنجی واقعی در Server
- UI: صفحه لاگین + دکمه خروج + داشبورد اولیه
- authorize.service: authenticateRequest + requirePermission (الگوی مرجع Authorize برای همه‌ی Routeها)
- لاگ LOGIN / LOGOUT

### Feature: Activity Logs (هسته)
- سرویس مرکزی logActivity — تمام فیچرها فقط از طریق این Service لاگ ثبت می‌کنند
- API لیست/فیلتر لاگ‌ها: هنوز ساخته نشده

### Feature: Users (بک‌اند کامل — UI ندارد)
- API: GET/POST /api/v1/users | GET/PATCH/DELETE /api/v1/users/:userId
- pagination + search + فیلتر isActive | Soft Delete | عدم عبور passwordHash از لایه DTO
- Business Rules: عدم حذف/غیرفعال‌سازی حساب خود

### Feature: Roles & Permissions (بک‌اند کامل — UI ندارد)
- API: GET/POST /api/v1/roles | PATCH/DELETE /api/v1/roles/:roleId | GET /api/v1/permissions
- Business Rules: عدم حذف نقش دارای کاربر، اعتبارسنجی وجود permissionIds/roleIds

---

## 🔜 قدم‌های بعدی (به ترتیب)

1. UI مدیریت کاربران و نقش‌ها (بر اساس docs/14-ui-design-brief.md)
2. Feature: Repair Tickets (پذیرش) — Customer/Device/Brand/Model + API + UI
3. Feature: Part Requests — چرخه‌ی وضعیت + StatusHistory + API + UI
4. Feature: Purchasing (صف خرید، ثبت خرید، هشدار اختلاف قیمت، عدم موجودی، مرجوعی)
5. Feature: Vendors + Pricing/Price History
6. API و UI لاگ فعالیت‌ها
7. Dashboard آماری

---

## 📝 تصمیمات فنی ثبت‌شده

- خطاها از AppError مشتق می‌شوند و handleApiError آن‌ها را به HTTP Status نگاشت می‌کند
- رکوردهای اتصال (user_roles, role_permissions, sessions) مشمول Soft Delete نیستند؛ تاریخچه در Activity Log ثبت می‌شود
- ارتباط بین فیچرها فقط از طریق Service (نمونه: users → permissions با assertRolesExist)
