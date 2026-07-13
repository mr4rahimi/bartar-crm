# Repair ERP

سیستم مدیریت تعمیرات، خرید قطعات و خدمات پس از فروش.

> ⚠️ قبل از هرگونه توسعه، فایل‌های داخل پوشه `docs/` باید مطالعه شوند
> (به‌خصوص `11-AI_INSTRUCTIONS.md` و `10-development-rules.md`).

## Tech Stack

- Next.js 14 (App Router) + TypeScript
- Tailwind CSS + shadcn/ui
- PostgreSQL + Prisma
- Zod + React Hook Form
- TanStack Query

## Getting Started

```bash
# 1. نصب پکیج‌ها
npm install

# 2. تنظیم متغیرهای محیطی
cp .env.example .env
# سپس DATABASE_URL را ویرایش کنید

# 3. اجرای مایگریشن
npm run prisma:migrate

# 4. اجرای seed (نقش‌ها و مجوزهای پیش‌فرض)
npm run prisma:seed

# 5. اجرای پروژه
npm run dev
```

## Folder Structure

این پروژه از معماری **Feature-First** پیروی می‌کند (نه Layer-First).
جزئیات کامل در `docs/07-folder-structure.md`.

```
app/            → صفحات و روت‌ها (App Router)
features/       → هر Feature مستقل با components/actions/services/repositories/...
shared/         → کامپوننت‌ها و ابزارهای مشترک
prisma/         → schema و migrations
docs/           → مستندات کامل پروژه (منبع مرجع)
```

## Golden Rules (خلاصه از docs/11-AI_INSTRUCTIONS.md)

- Business Logic فقط داخل `services/`
- Prisma فقط داخل `repositories/`
- هیچ Validation دستی — همیشه Zod
- هیچ Delete فیزیکی — همیشه Soft Delete (`deletedAt`)
- هر عملیات مهم باید Permission-checked و Logged باشد
- هیچ `any` در TypeScript

## Current Phase

**Phase 1 — Part Purchasing Management**
(به `docs/02-PROJECT_CHARTER.md` مراجعه شود)

اسکوپ فعلی: Authentication, Users, Roles, Permissions, Repair Ticket,
Part Request, Purchasing, Pricing, Vendors, Activity Logs.

خارج از اسکوپ فعلی: Inventory, CRM, Warranty, Accounting.
# bartar-crm
