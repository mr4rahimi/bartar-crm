# Versioning & Changelog

## استاندارد
- نسخه‌گذاری: **SemVer** (`MAJOR.MINOR.PATCH`)
  - MAJOR: تغییر ناسازگار در جریان کاری یا داده
  - MINOR: قابلیت جدید سازگار با نسخه‌ی قبل
  - PATCH: رفع اشکال یا بهبود جزئی
- قالب تغییرات: **Keep a Changelog** با دسته‌های افزوده شد / تغییر کرد / اصلاح شد / امنیتی

## منبع واحد حقیقت
`shared/constants/changelog.ts` — هم صفحه‌ی `/about` از آن می‌خواند، هم `CHANGELOG.md` از آن تولید می‌شود.
`CHANGELOG.md` و فیلد `version` در `package.json` تولیدی هستند و نباید دستی ویرایش شوند.

## روال انتشار
1. ورودی جدید را به **ابتدای** آرایه‌ی `CHANGELOG` اضافه کن (نسخه، تاریخ، عنوان، تغییرات).
2. `npm run changelog` (تولید CHANGELOG.md + هم‌سان‌سازی package.json)
3. `npx tsc --noEmit && npm run build`
4. commit + push، سپس `./deploy.sh`

## نگارش تغییرات
متن‌ها برای کاربر نهایی نوشته می‌شوند، نه توسعه‌دهنده: به‌جای «افزودن endpoint برای X» بنویس «امکان انجام X».
