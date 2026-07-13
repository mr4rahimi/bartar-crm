# User Roles & Permission System

## Overview

سیستم از Role-Based Access Control (RBAC) به همراه Permission-Based Authorization استفاده می‌کند.

هیچ بخشی از سیستم نباید دسترسی‌ها را بر اساس Role بررسی کند.

همیشه Permission بررسی می‌شود.

Role فقط مجموعه‌ای از Permissionها است.

---

# Core Concepts

Permission
↓

Role
↓

User

---

# Default Roles

## Super Admin

دسترسی کامل

Permission: *

---

## Admin

مدیریت کاربران

مدیریت قطعات

مدیریت فروشندگان

مشاهده گزارش‌ها

مدیریت قیمت‌ها

مدیریت تنظیمات

---

## Reception

ثبت پذیرش

ثبت درخواست قطعه

ویرایش درخواست

ثبت تایید مشتری

ثبت بیعانه

مشاهده وضعیت خرید

---

## Technician

ثبت درخواست قطعه

ویرایش درخواست خود

ثبت تست

ثبت مصرف قطعه

ثبت مرجوعی

---

## Buyer

مشاهده صف خرید

شروع خرید

ثبت خرید

ثبت فروشنده

ثبت قیمت خرید

ثبت عدم موجودی

ثبت مرجوعی

---

## Pricing Operator

مدیریت قیمت قطعات

مدیریت تاریخچه قیمت

---

## Viewer

فقط مشاهده

هیچ عملیاتی ندارد

---

# Permission List

Authentication

LOGIN

LOGOUT

---

Repair

CREATE_REPAIR

EDIT_REPAIR

VIEW_REPAIR

DELETE_REPAIR

---

Part Request

CREATE_PART_REQUEST

EDIT_PART_REQUEST

DELETE_PART_REQUEST

VIEW_PART_REQUEST

CHANGE_STATUS

---

Purchase

START_PURCHASE

REGISTER_PURCHASE

EDIT_PURCHASE

RETURN_PURCHASE

NOT_FOUND

---

Pricing

VIEW_PRICE

EDIT_PRICE

VIEW_PRICE_HISTORY

---

Vendor

CREATE_VENDOR

EDIT_VENDOR

DELETE_VENDOR

VIEW_VENDOR

---

Users

CREATE_USER

EDIT_USER

DELETE_USER

VIEW_USER

---

Roles

CREATE_ROLE

EDIT_ROLE

DELETE_ROLE

ASSIGN_ROLE

---

Permission

ASSIGN_PERMISSION

---

Logs

VIEW_ACTIVITY_LOG

VIEW_SYSTEM_LOG

---

Reports

VIEW_REPORTS

EXPORT_REPORTS

---

Settings

VIEW_SETTINGS

EDIT_SETTINGS

---

# Authorization Rules

هیچ Route نباید فقط با Role محافظت شود.

همیشه Permission بررسی شود.

---

# Future Roles

سیستم باید امکان ایجاد Role جدید بدون تغییر کد را داشته باشد.

---

# Dynamic Permission

ادمین می‌تواند:

- Permission جدید ایجاد کند.
- Role جدید ایجاد کند.
- Permissionها را به Role اختصاص دهد.

---

# Audit

تمام تغییرات Role و Permission باید Log شوند.
