# Domain Model

## Introduction

این سند ساختار منطقی سیستم را تعریف می‌کند.

تمرکز این سند بر موجودیت‌های کسب‌وکار است، نه دیتابیس.

جداول دیتابیس باید بر اساس این مدل طراحی شوند.

---

# Domain Overview

Repair Ticket
    │
    ├── Customer
    ├── Device
    └── Part Requests
            │
            ├── Purchase
            ├── Vendor
            ├── Price History
            ├── Status History
            ├── Attachments
            └── Activity Logs

---

# Aggregate Root

در فاز اول پروژه، موجودیت اصلی سیستم:

Part Request

است.

تمام عملیات خرید حول این موجودیت انجام می‌شود.

---

# Entities

## User

نماینده یکی از کاربران سیستم.

مسئولیت‌ها:

- ورود
- ثبت اطلاعات
- انجام عملیات
- ثبت لاگ

---

## Role

تعریف نقش‌های سیستم.

مثال:

Reception

Technician

Buyer

Admin

---

## Permission

هر قابلیت سیستم.

Role فقط مجموعه‌ای از Permissionها است.

---

## Customer

اطلاعات مشتری.

در فاز اول فقط جهت ارتباط با Repair Ticket استفاده می‌شود.

---

## Repair Ticket

نماینده پذیرش تعمیر.

ویژگی‌ها:

- شماره پذیرش
- مشتری
- دستگاه
- وضعیت
- چندین درخواست قطعه

---

## Device

دستگاه مشتری.

شامل:

برند

مدل

IMEI (در آینده)

Serial

---

## Brand

Apple

Samsung

Xiaomi

...

---

## Model

iPhone 13

Galaxy A54

...

---

## Part

تعریف قطعه.

مثال:

LCD

Battery

Camera

Charging Port

...

---

## Part Quality

Original

High Copy

Copy

---

## Part Request

مهم‌ترین Entity پروژه.

هر Part Request فقط مربوط به یک قطعه است.

اما:

هر Repair Ticket

می‌تواند

چندین Part Request داشته باشد.

---

Part Request شامل:

- قطعه
- کیفیت
- برند
- مدل
- وضعیت
- مبلغ پرداختی مشتری
- Test Mode
- توضیحات
- ثبت کننده

---

## Purchase

اطلاعات خرید.

شامل:

- فروشنده
- قیمت خرید
- زمان خرید
- خریدار
- توضیحات

---

## Vendor

فروشنده قطعات.

ویژگی‌ها:

- نام
- اطلاعات تماس
- آدرس (اختیاری)
- فعال / غیرفعال

---

## Price History

تمام خریدها در این جدول ثبت می‌شوند.

هدف:

تحلیل قیمت.

---

## Status History

تمام تغییر وضعیت‌ها.

مثلاً:

Waiting Approval

↓

Approved

↓

Purchased

↓

Delivered

---

## Activity Log

تمام عملیات کاربران.

---

## Attachment

در آینده.

تصاویر

فاکتور

رسید

---

# Relationships

Repair Ticket

1

↓

N

Part Request

---

Part Request

1

↓

1

Purchase

(در فاز اول)

در آینده

1

↓

N

Purchase

برای مرجوعی و خرید مجدد.

---

Vendor

1

↓

N

Purchase

---

Part

1

↓

N

Part Request

---

User

1

↓

N

Activity Log

---

# Domain Rules

هیچ Entity نباید مستقیماً Entity دیگر را تغییر دهد.

تمام تغییرات باید از طریق Business Service انجام شوند.

---

تمام تغییر وضعیت‌ها باید ثبت شوند.

---

تمام خریدها باید ثبت کننده داشته باشند.

---

تمام تغییرات قیمت باید قابل رهگیری باشند.
