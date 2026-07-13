# Workflow Definition

## Overview

این سند فرآیندهای اصلی سیستم را تعریف می‌کند.

هیچ توسعه‌ای نباید خارج از این Workflow انجام شود.

---

# Workflow 1

ثبت درخواست قطعه

Technician

↓

Create Part Request

↓

Status

CREATED

---

# Workflow 2

اعلام هزینه

Reception

↓

ثبت مبلغ

↓

Waiting Customer Approval

---

# Workflow 3

تایید مشتری

Customer

↓

Approve

↓

APPROVED

↓

Waiting Purchase

---

Customer

↓

Reject

↓

REJECTED

---

# Workflow 4

ثبت بیعانه

Reception

↓

ثبت مبلغ پرداختی

↓

Update Deposit

↓

Log

---

# Workflow 5

صف خرید

Buyer

↓

مشاهده درخواست‌ها

↓

شروع خرید

↓

PURCHASING

---

# Workflow 6

عدم موجودی

Buyer

↓

Not Found

↓

NOT_FOUND

↓

بازگشت به صف خرید

در آینده

---

# Workflow 7

ثبت خرید

Buyer

↓

ثبت فروشنده

↓

ثبت قیمت

↓

ثبت توضیحات

↓

PURCHASED

---

# Workflow 8

تحویل تعمیرکار

Buyer

↓

Deliver

↓

DELIVERED

---

# Workflow 9

مصرف

Technician

↓

Installed

↓

CONSUMED

---

# Workflow 10

مرجوعی

Technician

↓

Wrong Part

↓

RETURN_REQUEST

↓

Buyer

↓

Vendor Return

↓

RETURNED

↓

Create Purchase Again

---

# Workflow 11

تست

Technician

↓

Test Mode

↓

Purchase

↓

Install

↓

Success

↓

Need Customer Approval

↓

New Purchase

یا

↓

Failed

↓

Return

---

# State Machine

CREATED

↓

WAITING_CUSTOMER

↓

APPROVED

↓

WAITING_PURCHASE

↓

PURCHASING

↓

PURCHASED

↓

DELIVERED

↓

CONSUMED

↓

CLOSED

---

# Side States

REJECTED

NOT_FOUND

RETURNED

CANCELLED

---

# Allowed Transitions

CREATED

↓

WAITING_CUSTOMER

---

WAITING_CUSTOMER

↓

APPROVED

↓

REJECTED

---

APPROVED

↓

WAITING_PURCHASE

---

WAITING_PURCHASE

↓

PURCHASING

↓

NOT_FOUND

---

PURCHASING

↓

PURCHASED

↓

NOT_FOUND

---

PURCHASED

↓

DELIVERED

↓

RETURNED

---

DELIVERED

↓

CONSUMED

↓

RETURNED

---

CONSUMED

↓

CLOSED

---

# Forbidden Transitions

CREATED

×

PURCHASED

---

WAITING_CUSTOMER

×

DELIVERED

---

NOT_FOUND

×

CONSUMED

---

RETURNED

×

CLOSED

---

# Audit Rules

هر تغییر وضعیت باید شامل موارد زیر باشد:

- User
- Date
- Time
- Previous Status
- New Status
- Description

---

# Notification Rules

در آینده:

تغییر وضعیت‌ها

اعلان تولید خواهند کرد.

مثال:

Customer Approved

↓

Buyer Notification

---

Purchased

↓

Technician Notification

---

Not Found

↓

Reception Notification
