# ایمپورت پذیرش‌های قدیمی به Bartar CRM

## فایل‌ها
- `import_payload.json` — ۱۱۶۰۲ رکورد پذیرش، تمیز و آماده (خروجی پردازش اکسل)
- `import-legacy-reception.js` — اسکریپت Node.js که با Prisma Client فقط رکورد جدید اضافه می‌کند
- `reports/summary.txt` و فایل‌های CSV گزارش — ردیف‌های کنار گذاشته‌شده و تناقض‌ها

هر دو فایل `import_payload.json` و `import-legacy-reception.js` را کنار هم در یک پوشه
(مثلاً داخل پروژه، کنار `schema.prisma`) بگذار.

## قبل از هر اجرا
```bash
npm ls @prisma/client   # مطمئن شو نصب است
```

## مرحله ۱ — لوکال، حالت گزارش (dry-run، بدون نوشتن)
```bash
cd ~/Projects/bartar-crm
node import-legacy-reception.js
```
خروجی رو با هم مرور می‌کنیم: تعداد پذیرش قابل‌ایجاد، برند/مدل/نوع دستگاه جدید،
مشتری جدید در برابر تطبیق‌یافته، و هر خطایی.

## مرحله ۲ — لوکال، اجرای واقعی
```bash
node import-legacy-reception.js --commit
```

## مرحله ۳ — بررسی نتیجه در لوکال
```sql
SELECT count(*) FROM repair_tickets;
SELECT * FROM repair_tickets ORDER BY "createdAt" DESC LIMIT 5;
```
مطمئن شو رکوردهای قبلی (قبل از ایمپورت) دست‌نخورده مونده‌ن.

## مرحله ۴ — روی سرور (فقط بعد از تایید کامل روی لوکال)

⚠️ **حتماً اول بک‌آپ بگیر:**
```bash
pg_dump "postgresql://bartar_crm:BartarCRM_2026_9vL@127.0.0.1:5432/bartar_crm_db" \
  -F c -f /root/backups/bartar_crm_before_import_$(date +%Y%m%d_%H%M).dump
```

بعد همون دو فایل (`import_payload.json` و `import-legacy-reception.js`) رو به سرور منتقل کن
(مثلاً با `scp`)، و چون `.env` سرور از قبل به دیتابیس سرور اشاره داره، فقط کافیه:

```bash
cd /var/www/bartar-crm
node import-legacy-reception.js          # dry-run — خط اول خروجی رو چک کن ببین
                                          # DATABASE_URL درست همون دیتابیس سرور رو نشون میده
node import-legacy-reception.js --commit
```

اگر لازم بود برگردی عقب:
```bash
pg_restore --clean --if-exists -d bartar_crm_db /root/backups/bartar_crm_before_import_XXXX.dump
```

## نکات ایمنی که در اسکریپت رعایت شده
- هیچ `UPDATE` یا `DELETE`ای روی هیچ جدولی انجام نمی‌شود — فقط `CREATE`/`UPSERT` روی
  موجودیت‌های مرجع (برند/مدل/نوع دستگاه) و `CREATE` روی مشتری/دستگاه/پذیرش.
- **Idempotent**: قبل از ساخت هر پذیرش، چک می‌شود `ticketNumber` از قبل وجود دارد یا نه؛
  اگر بود، رد می‌شود. یعنی اگر اسکریپت وسط راه قطع بشه یا دوباره اجرا بشه، دوباره‌کاری
  یا رکورد تکراری ایجاد نمی‌شود.
- مشتری بر اساس شماره موبایل جستجو می‌شود؛ اگر موجود بود دوباره ساخته نمی‌شود.

## داده‌هایی که کنار گذاشته شدند (در reports/)
- `skipped_no_phone.csv` — ۵۱ ردیف بدون شماره موبایل
- `receipt_no_conflicts.csv` — ردیف‌هایی با شماره پذیرش تکراری/متناقض (فقط اولی وارد شد)
