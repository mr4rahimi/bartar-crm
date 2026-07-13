# Development Rules

Version: 1.0

---

# Purpose

این سند قوانین توسعه پروژه را مشخص می‌کند.

تمام اعضای تیم و تمام ابزارهای هوش مصنوعی موظف به رعایت این قوانین هستند.

در صورت تضاد بین کد و این سند، این سند مرجع اصلی است.

---

# Philosophy

Business First

Feature First

Type Safe

Maintainable

Scalable

Readable

Predictable

---

# General Rules

کد باید طوری نوشته شود که خواندن آن آسان‌تر از نوشتن آن باشد.

کد کوتاه‌تر همیشه بهتر نیست.

واضح‌تر بهتر است.

---

# Business Logic

هیچ Business Logic داخل فایل‌های زیر مجاز نیست:

- page.tsx
- layout.tsx
- components
- hooks

Business Logic فقط داخل Service قرار می‌گیرد.

---

# Components

Component فقط مسئول نمایش UI است.

Component نباید:

- Query اجرا کند.
- Permission بررسی کند.
- Validation انجام دهد.
- Prisma صدا بزند.
- SQL اجرا کند.

---

# Services

تمام قوانین کسب‌وکار داخل Service قرار می‌گیرند.

مثال:

CreatePartRequest

ApproveCustomer

RegisterPurchase

ReturnPurchase

UpdatePriceHistory

---

# Repository

Repository فقط مسئول ارتباط با Prisma است.

Repository هیچ تصمیمی نمی‌گیرد.

Repository فقط:

Create

Read

Update

Delete

انجام می‌دهد.

---

# Validation

تمام Validationها باید توسط Zod انجام شوند.

هیچ Validation دستی داخل Component مجاز نیست.

---

# Prisma

Prisma فقط داخل Repository استفاده می‌شود.

هیچ Component یا Route نباید Prisma را مستقیماً صدا بزند.

---

# Route Handlers

Route فقط مسئول:

Authentication

Authorization

Validation

Call Service

Return Response

است.

هیچ Business Logic داخل Route مجاز نیست.

---

# Error Handling

هیچ Error خام به کاربر نمایش داده نشود.

تمام Errorها:

Log شوند.

پیام مناسب داشته باشند.

---

# Naming Convention

Folders

kebab-case

Files

kebab-case

Components

PascalCase

Variables

camelCase

Functions

camelCase

Enums

PascalCase

Interfaces

PascalCase

Types

PascalCase

Constants

UPPER_SNAKE_CASE

---

# Folder Rules

هر Feature مستقل باشد.

Featureها نباید مستقیماً به یکدیگر وابسته شوند.

---

# Function Rules

هر Function فقط یک مسئولیت داشته باشد.

اگر Function بیشتر از 50 خط شد،

نیاز به بازنگری دارد.

---

# File Rules

هر فایل حداکثر

300

خط.

---

# Component Rules

Component بیشتر از

200

خط نباشد.

---

# Service Rules

Service باید تست‌پذیر باشد.

Service نباید وابسته به UI باشد.

---

# State Management

React Query

برای داده‌های Server

Context

برای Stateهای Global

useState

برای Stateهای Local

Redux استفاده نشود مگر در آینده نیاز واقعی ایجاد شود.

---

# Logging

تمام عملیات مهم Log شوند.

Create

Edit

Delete

Approve

Purchase

Return

Permission Change

Login

Logout

---

# Security

هیچ Permission داخل UI قابل اعتماد نیست.

Backend همیشه دوباره Permission را بررسی می‌کند.

---

# Soft Delete

هیچ Delete واقعی انجام نشود.

deletedAt

استفاده شود.

---

# Audit

تمام تغییرات مهم باید قابل رهگیری باشند.

---

# Future Compatibility

هیچ توسعه‌ای نباید باعث وابستگی مستقیم بین:

Inventory

CRM

Accounting

Warranty

شود.

تمام ارتباطات باید از طریق Service انجام شوند.

---

# Code Review Checklist

قبل از Merge بررسی شود:

✓ TypeScript Error ندارد

✓ ESLint Error ندارد

✓ Validation دارد

✓ Permission دارد

✓ Log دارد

✓ Business Rule رعایت شده

✓ Naming صحیح است

✓ Test در صورت نیاز نوشته شده

✓ Documentation به‌روز شده
