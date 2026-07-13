# Project Charter

## Project Name

Repair ERP

---

## Mission

طراحی و توسعه یک پلتفرم یکپارچه جهت مدیریت فرآیند تعمیرات، خرید قطعات، مشتریان، انبار و خدمات پس از فروش.

---

## Current Phase

Phase 1

Part Purchasing Management

---

## Long-Term Vision

تبدیل سیستم به ERP اختصاصی مجموعه شامل:

- Repairs
- Purchasing
- Inventory
- CRM
- Warranty
- Accounting
- Reporting

---

## Core Principles

### Business First

تمام توسعه‌ها باید بر اساس فرآیندهای کسب‌وکار انجام شوند.

صفحات و رابط کاربری در اولویت دوم هستند.

---

### Mobile First

تمام صفحات ابتدا برای موبایل طراحی شوند.

---

### Auditability

تمام عملیات کاربران باید قابل رهگیری باشد.

هیچ داده‌ای نباید بدون ثبت سابقه تغییر کند.

---

### Extensibility

تمام ساختارها باید برای توسعه‌های آینده آماده باشند.

---

### No Hard Delete

هیچ رکوردی حذف فیزیکی نمی‌شود.

---

### Permission Based

تمام دسترسی‌ها از طریق Permission کنترل می‌شوند.

---

### Modular Architecture

هر ماژول مستقل توسعه داده می‌شود.

---

## Current Scope

سیستم مدیریت خرید قطعات

---

## Out Of Scope

- حسابداری
- انبارداری
- باشگاه مشتریان
- گارانتی
- CRM

این موارد در فازهای بعدی توسعه خواهند یافت.

---

## Technology Stack

Frontend:
- Next.js
- TypeScript
- Tailwind
- shadcn/ui

Backend:
- Next.js Route Handlers

Database:
- PostgreSQL

ORM:
- Prisma

Validation:
- Zod

Forms:
- React Hook Form

Data Fetching:
- TanStack Query

Deployment:
- Ubuntu VPS
- Docker
- Nginx

---

## Golden Rule

هر Feature جدید باید قبل از توسعه با قوانین Business Rules مطابقت داده شود.
