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

---

## ⚠️ تغییر Scope (2026/07/14)

- پذیرش فعلاً با نرم‌افزار خارجی انجام می‌شود؛ فیچر repairs در این فاز فقط نگهداری می‌شود و توسعه‌ی بیشتر آن به فاز بعد موکول شد.
- Part Request به تیکت داخلی وابسته نیست: فیلد receptionNumber (متن آزاد از نرم‌افزار پذیرش خارجی) جایگزین اتصال اجباری به RepairTicket می‌شود (repairTicketId اختیاری می‌ماند برای آینده).
- اولویت فاز جاری: ۱) ثبت درخواست قطعه برای خرید ۲) تایید و ثبت خرید. سپس: سینک قیمت‌ها با نرم‌افزار اعلام هزینه (جزئیات از کارفرما دریافت می‌شود).
- ورودی‌های شماره موبایل در کل سیستم ارقام فارسی/عربی را می‌پذیرند (نرمال‌سازی در Zod).

---

## ✅ تکمیل‌شده (ادامه — 2026/07/14)

### Design System + App Shell
- توکن‌های رنگی از ماکاپ ui/ (روشن/تیره، پیش‌فرض تیره + سوییچر)، فونت Vazirmatn، RTL سراسری
- Shell: سایدبار دسکتاپ + Bottom Nav موبایل با فیلتر آیتم‌ها بر اساس Permission
- کامپوننت‌های پایه: Button, Input, Label, Badge, Dialog (BottomSheet/Modal), Switch, Textarea, Skeleton, Toast, StatusChip

### Feature: Users & Roles (کامل با UI)
- صفحات /users و /roles: لیست کارتی/جدولی، فرم‌ها، ماتریس دسترسی گروه‌بندی‌شده با انتخاب گروهی، دیالوگ حذف

### Feature: Repairs (نگهداری — توسعه به فاز بعد موکول شد)
- ثبت پذیرش با ساخت سریع مشتری، Upsert برند/مدل، شماره تیکت صعودی — فعلاً پذیرش با نرم‌افزار خارجی است

### Feature: Part Requests (کامل — قلب سیستم)
- Schema: receptionNumber (متن آزاد)، quantity، repairTicketId اختیاری
- ماشین وضعیت داده‌محور (ACTION_DEFS) دقیقاً طبق 05-workflows.md + تفسیرها:
  NOT_FOUND→WAITING_PURCHASE مجاز | APPROVE خودکار وارد صف خرید (دو رکورد History) |
  CANCELLED فقط از CREATED/WAITING_CUSTOMER/APPROVED/WAITING_PURCHASE
- هر گذار: StatusHistory (تراکنشی) + ActivityLog | گذار غیرمجاز → 409
- UI: لیست با چیپ‌های وضعیت رنگی + فرم ثبت + صفحه جزئیات با تایم‌لاین و اکشن‌های وابسته به وضعیت/Permission
- نرمال‌سازی ارقام فارسی در همه‌ی ورودی‌های عددی/موبایل

### زیرساخت‌های افزوده
- AppError/handleApiError، apiFetch با نمایش خطای فیلدها، positiveIntField، useDebouncedValue

## 🔜 قدم‌های بعدی (به‌روزشده)
1. Pricing Integration مرحله ۱ و ۲ (Schema تاکسونومی + اتصال فرم درخواست) — docs/15-pricing-integration.md
2. Feature: Purchasing با Auto-Pricing
3. صفحه عمومی /prices + پنل مدیریت قیمت
4. Import داده از price-next
5. Vendors UI | لاگ فعالیت‌ها | Dashboard آماری

---

## ✅ تکمیل‌شده (ادامه — آماده‌ی استقرار نسخه‌ی اول)

### Feature: Purchasing (کامل)
- صف خرید (تب‌های در صف / در حال خرید / خریدهای اخیر)، ثبت خرید با ساخت سریع فروشنده
- Auto-Pricing: نسبت قبلی فروش/خرید یا ۱.۳+ با پرچم needsReview | هشدار اختلاف قیمت (بدون مسدودسازی) | مرجوعی

### Feature: Pricing (کامل)
- Import کامل داده از price-next (اسکریپت scripts/import-price-next.ts — create-only و قابل اجرای مجدد)
- صفحه عمومی /prices بدون احراز هویت + پنل داخلی /pricing (خرید فقط با EDIT_PRICE)
- لیست تخت با جستجوی لایو مثل price-next | لِجند رنگی کیفیت‌ها + خط رنگی راست هر باکس | تاریخچه قیمت | افزودن/ویرایش دستی (پاک شدن پرچم بازبینی)

### Dashboard
- کارت‌های آمار، نمودار روند خرید ۱۴ روزه (Area)، نمودار وضعیت درخواست‌ها (Bar با رنگ خانواده‌ها)، آخرین درخواست‌ها، بنر قیمت‌های نیازمند بازبینی — رفرش خودکار هر دقیقه

### نکات Build و استقرار
- فونت Vazirmatn از پکیج npm لوکال سرو می‌شود (بدون نیاز به اینترنت در build)
- تایپ ورودی فرم‌ها با z.input (رشته مجاز، transform در Zod)
- راهنمای استقرار: docs/16-deployment.md

## 🔜 باقی‌مانده برای فازهای بعد
Vendors UI مستقل | صفحه لاگ فعالیت‌ها | تکمیل پذیرش داخلی | بیعانه | Attachments | گزارش‌ها

---

## 🚀 نسخه ۱ — آماده‌ی استقرار (2026/07/16)

### افزوده‌های نهایی
- لندینگ عمومی / (Hero + دکمه ورود + مشاهده قیمت‌ها)
- مدیریت کاتالوگ /catalog: CRUD کامل نوع دستگاه/برند/مدل/قطعه با حذف مشروط به وابستگی (Permission: EDIT_PRICE)
- ساخت سریع برند از فرم درخواست با PromptDialog (جایگزین window.prompt)
- Import کامل داده price-next انجام شده (برندها/مدل‌ها/قطعات/قیمت‌های فروش)

### بازبینی پیش از استقرار (انجام شد)
- کاربر غیرفعال/حذف‌شده بلافاصله از تمام Sessionها خارج می‌شود (فیلتر isActive/deletedAt در findUserById احراز هویت)
- /catalog به matcher میدل‌ور اضافه شد
- بعد از ثبت خرید، کوئری‌های قیمت (price-list, prices-review) invalidate می‌شوند
- بایند دیتابیس در راهنمای استقرار به 127.0.0.1 محدود شد + چک‌لیست production

### محدودیت‌های شناخته‌شده‌ی نسخه ۱ (برای فازهای بعد)
- Vendors فقط با ساخت سریع از فرم خرید مدیریت می‌شوند (UI مستقل ندارد)
- صفحه لاگ فعالیت‌ها ساخته نشده (داده کامل در activity_logs ثبت می‌شود)
- پذیرش داخلی حداقلی است (پذیرش با نرم‌افزار خارجی)
- بیعانه (depositAmount) در UI ورودی ندارد
- تمدید کوکی Session فقط در /api/v1/auth/me انجام می‌شود (کاربر عملاً هر ۳۰ روز یک‌بار لاگین می‌کند)
