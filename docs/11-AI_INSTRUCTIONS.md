# AI Development Instructions

Project: Repair ERP

---

## Purpose

این سند رفتار مورد انتظار از هر هوش مصنوعی هنگام توسعه پروژه را مشخص می‌کند.

AI باید قبل از هرگونه تولید کد این فایل و تمام فایل‌های پوشه docs را مطالعه کند.

---

# Golden Rule

هرگز قوانین Business را تغییر نده.

اگر نیاز به تغییر Business Rule وجود داشت،

ابتدا پیشنهاد بده،

نه اینکه مستقیم تغییر ایجاد کنی.

---

# Architecture

این پروژه بر اساس Modular Monolith طراحی شده است.

هیچ کدی نباید این معماری را نقض کند.

---

# Feature Based

همه کدهای جدید داخل Feature مناسب قرار بگیرند.

هرگز فایل جدید خارج از ساختار پروژه ایجاد نکن.

---

# Business First

ابتدا فرآیند کسب‌وکار را درک کن.

سپس کد تولید کن.

---

# Existing Pattern

همیشه از الگوی موجود پروژه پیروی کن.

هرگز Style جدید ایجاد نکن.

---

# Prisma

هرگز Schema را بدون Migration تغییر نده.

هرگز Migration را حذف نکن.

هرگز Prisma Client را داخل Component استفاده نکن.

---

# Route Handler

Route فقط باید:

Validate

↓

Authorize

↓

Call Service

↓

Return Response

انجام دهد.

---

# UI

از Componentهای موجود استفاده کن.

اگر Component وجود دارد،

Component جدید نساز.

---

# Design System

از shadcn/ui استفاده کن.

Style جدید نساز مگر نیاز واقعی وجود داشته باشد.

---

# Validation

همیشه Zod.

هیچ Validation دستی تولید نکن.

---

# Data Fetching

همیشه TanStack Query.

Fetch مستقیم داخل Component انجام نده.

---

# TypeScript

هرگز از any استفاده نکن.

تا جای ممکن از Type Inference استفاده کن.

---

# Permission

هیچ عملیات مهمی بدون Permission انجام نشود.

---

# Logs

هر عملیات مهم باید Audit Log تولید کند.

---

# Status

هر تغییر Status باید:

ثبت شود.

Log شود.

اعتبارسنجی شود.

---

# Database

هیچ Table بدون:

createdAt

updatedAt

طراحی نشود.

برای موجودیت‌های اصلی:

deletedAt

نیز وجود داشته باشد.

---

# Documentation

اگر Feature جدید ایجاد شد،

فایل مربوطه داخل docs نیز به‌روزرسانی شود.

---

# Performance

از Queryهای غیرضروری جلوگیری کن.

N+1 Query تولید نکن.

---

# Refactoring

اگر کد قابل بهبود است،

ابتدا پیشنهاد بده.

بدون هماهنگی Refactor بزرگ انجام نده.

---

# Forbidden

هرگز:

Business Rule را تغییر نده.

Permission را حذف نکن.

Validation را حذف نکن.

Log را حذف نکن.

TypeScript را دور نزن.

هرگز از any استفاده نکن.

Database را مستقیم از UI صدا نزن.

Business Logic داخل Component قرار نده.

Business Logic داخل Route قرار نده.

---

# Response Style

قبل از تولید کد:

۱- مسئله را توضیح بده.

۲- راهکار را توضیح بده.

۳- اثر تغییر را توضیح بده.

۴- سپس کد تولید کن.

---

# When Unsure

اگر درباره قوانین پروژه مطمئن نیستی،

کد تولید نکن.

ابتدا سؤال بپرس.

---

# Priority

در صورت تضاد:

1. PROJECT_CHARTER.md

2. BUSINESS_RULES.md

3. DOMAIN_MODEL.md

4. WORKFLOWS.md

5. DEVELOPMENT_RULES.md

6. سایر فایل‌ها

---

# Final Goal

هدف این پروژه فقط تولید کد نیست.

هدف تولید یک ERP پایدار، قابل توسعه و قابل نگهداری برای سال‌های آینده است.
