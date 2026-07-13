# Project Folder Structure

## Principle

Feature First Architecture

نه Layer First

---

app/

auth/

dashboard/

purchases/

repairs/

settings/

api/

---

features/

authentication/

users/

permissions/

repairs/

part-requests/

purchases/

vendors/

pricing/

dashboard/

settings/

---

هر Feature شامل:

components/

actions/

services/

repositories/

validators/

schemas/

hooks/

types/

constants/

utils/

---

shared/

components/

hooks/

lib/

constants/

validators/

types/

icons/

---

prisma/

schema.prisma

migrations/

seed.ts

---

docs/

تمام مستندات پروژه

---

public/

uploads/

images/

icons/

---

tests/

unit/

integration/

---

types/

global.d.ts

---

middleware.ts

---

# Rules

هیچ Feature نباید مستقیم به Feature دیگر وابسته باشد.

---

ارتباط بین Featureها فقط از طریق Service انجام شود.

---

هیچ Business Logic داخل Component قرار نگیرد.

---

هیچ Query داخل Component نوشته نشود.

---

هیچ Prisma Client داخل UI استفاده نشود.

---

همه Validationها داخل validators قرار بگیرند.

---

همه Typeها داخل types قرار بگیرند.

---

هیچ فایل بیشتر از 300 خط نباشد.

در صورت بزرگ شدن Split شود.
