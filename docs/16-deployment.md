# Deployment — استقرار روی سرور

## پیش‌نیاز: Node.js 18+، Docker

## مراحل
```bash
git clone git@github.com:mr4rahimi/bartar-crm.git && cd bartar-crm
cp .env.example .env   # مقادیر production را تنظیم کن (حتماً SESSION_SECRET و پسورد دیتابیس قوی)

# دیتابیس
docker run -d --name bartar-crm-postgres --restart unless-stopped \
  -e POSTGRES_USER=bartar_user -e POSTGRES_PASSWORD=<STRONG_PASS> -e POSTGRES_DB=bartar_crm \
  -p 5438:5432 -v bartar_pgdata:/var/lib/postgresql/data postgres:16-alpine

npm install
npx prisma migrate deploy      # (نه migrate dev — روی production)
npm run prisma:seed            # Permissionها، Roleها، ادمین اولیه (BOOTSTRAP_* در .env)
npx tsx prisma/seed-device-types.ts
npx tsx scripts/import-price-next.ts price-db/price_db_plain_20260714_124140.sql

npm run build
pm2 start npm --name bartar-crm -- start   # پورت 3000
```

## نکات
- DATABASE_URL حتماً با 127.0.0.1 (نه localhost)
- NODE_ENV=production → کوکی Session با فلگ secure ست می‌شود؛ پس **HTTPS الزامی است** (nginx + certbot)
- بعد از اولین ورود، رمز ادمین Bootstrap را عوض کن
- صفحه /prices عمومی است؛ بقیه‌ی مسیرها پشت لاگین
- بکاپ: pg_dump روزانه از کانتینر (cron)
