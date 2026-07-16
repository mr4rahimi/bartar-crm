# Deployment — استقرار روی سرور

## پیش‌نیاز: Node.js 18+، Docker

## مراحل
```bash
git clone git@github.com:mr4rahimi/bartar-crm.git && cd bartar-crm
cp .env.example .env   # مقادیر production را تنظیم کن (حتماً SESSION_SECRET و پسورد دیتابیس قوی)

# دیتابیس
docker run -d --name bartar-crm-postgres --restart unless-stopped \
  -e POSTGRES_USER=bartar_user -e POSTGRES_PASSWORD=<STRONG_PASS> -e POSTGRES_DB=bartar_crm \
  -p 127.0.0.1:5438:5432 -v bartar_pgdata:/var/lib/postgresql/data postgres:16-alpine

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

## چک‌لیست قبل از استقرار (نسخه ۱)
- [ ] پورت دیتابیس فقط روی 127.0.0.1 بایند شده باشد (بالا)
- [ ] SESSION_SECRET و پسورد دیتابیس قوی و متفاوت با dev
- [ ] BOOTSTRAP_ADMIN_PASSWORD قوی + تعویض بعد از اولین ورود
- [ ] HTTPS با nginx + certbot (بدون آن کوکی لاگین در production کار نمی‌کند)
- [ ] Rate limit روی لاگین در nginx (جلوگیری از حدس رمز):
      limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
      و در location /api/v1/auth/login → limit_req zone=login burst=5;
- [ ] cron بکاپ روزانه:
      0 3 * * * docker exec bartar-crm-postgres pg_dump -U bartar_user bartar_crm | gzip > /backup/bartar_$(date +\%F).sql.gz
- [ ] پوشه price-db/ بعد از import روی سرور لازم نیست باقی بماند (حاوی هش پسورد سیستم قدیم است)
