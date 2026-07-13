# API Standards

## Principle

API باید کاملاً قابل پیش‌بینی باشد.

---

# Version

/api/v1/

---

# Naming

GET

POST

PATCH

DELETE

---

Plural

/api/v1/vendors

/api/v1/users

/api/v1/part-requests

---

# Response

Success

{
success:true,
data:{}
}

---

Error

{
success:false,
message:"",
errors:[]
}

---

# HTTP Status

200

Success

201

Created

400

Validation Error

401

Unauthorized

403

Forbidden

404

Not Found

409

Conflict

500

Internal Error

---

# Validation

تمام Requestها

قبل از ورود

توسط Zod بررسی شوند.

---

# Pagination

page

pageSize

sort

search

---

# Filter

status

vendor

brand

model

createdBy

createdAt

updatedAt

---

# Soft Delete

DELETE

نباید رکورد حذف کند.

deletedAt

ثبت شود.

---

# Authentication

Session Based

---

# Authorization

Permission Middleware

---

# Logging

تمام Mutationها Log شوند.

---

# API Rules

هیچ API نباید Business Logic داشته باشد.

Business Logic فقط داخل Service قرار می‌گیرد.

---

API فقط:

Validate

↓

Authorize

↓

Call Service

↓

Return Response
