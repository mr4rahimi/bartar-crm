# Pricing Integration — ادغام نرم‌افزار اعلام هزینه (price-next)

مرجع: https://github.com/mr4rahimi/price-next (در حال حاضر روی سرور جداگانه فعال است)

## هدف
نرم‌افزار اعلام هزینه‌ی فعلی با همان کارکرد در Bartar CRM ادغام می‌شود:
- صفحه عمومی قیمت‌ها (بدون نیاز به ورود) با همان تجربه‌ی کاربری
- مدیریت قیمت‌ها توسط ادمین (این‌بار: قیمت خرید + قیمت فروش)
- به‌روزرسانی خودکار قیمت فروش پس از هر خرید واقعی

## ساختار داده‌ی سیستم مبدا (price-next)
- DeviceType (موبایل، لپ‌تاپ، ...) → Brand → Model (unique: name+brand+deviceType)
- PartCategory (باتری، LCD، ...)
- Price: به ازای هر (Model + PartCategory) یک ردیف با سه قیمت فروش:
  originalPrice / copy1Price / copy2Price + notes

## نگاشت به مدل داده‌ی CRM
| price-next | Bartar CRM | توضیح |
|---|---|---|
| DeviceType | **DeviceType (جدید)** | اضافه می‌شود |
| Brand | Brand (موجود) | همان جدول brands |
| Model | DeviceModel (موجود) + فیلد deviceTypeId | یکتایی: brand+deviceType+name |
| PartCategory | Part (موجود) | همان جدول parts |
| Price (۳ ستون فروش) | **PartPrice (جدید)** — نرمال‌شده | یک ردیف به ازای (Model + Part + Quality) با buyPrice و sellPrice |

نگاشت کیفیت: originalPrice → ORIGINAL | copy1Price → HIGH_COPY | copy2Price → COPY

## قانون به‌روزرسانی خودکار قیمت (Auto-Pricing Rule)
هنگام «ثبت خرید» توسط مسئول خرید برای درخواستی که به (Model + Part + Quality) متصل است:
1. buyPrice جدید = قیمت خرید ثبت‌شده
2. اگر buyPrice و sellPrice قبلی هر دو موجود باشند:
   sellPrice جدید = خریدِ جدید × (sellPrice قبلی ÷ buyPrice قبلی)، گرد رو به پایین به مضرب ۱۰٬۰۰۰ تومان
3. اگر سابقه‌ی buyPrice قبلی وجود نداشته باشد (مثلاً فقط فروش از سیستم قدیم ایمپورت شده):
   فقط buyPrice ثبت می‌شود و sellPrice تغییر نمی‌کند (تنظیم دستی با ادمین)
4. هر تغییر (خرید و فروش) در PriceHistory با type مربوطه (BUY/SELL) ثبت می‌شود + ActivityLog

مثال: خرید قبلی ۱٬۵۰۰٬۰۰۰ / فروش ۲٬۰۰۰٬۰۰۰ → خرید جدید ۱٬۷۰۰٬۰۰۰
→ فروش جدید = 1,700,000 × (2,000,000/1,500,000) = 2,266,667 → **۲٬۲۶۰٬۰۰۰**

## نمایش و دسترسی
- **صفحه عمومی `/prices`:** بدون احراز هویت، فقط قیمت فروش. جستجو + انتخاب آبشاری نوع دستگاه/برند/مدل.
- **پذیرش/کاربران داخلی:** همان قیمت فروش را برای اعلام هزینه می‌بینند (VIEW_PRICE).
- **قیمت خرید:** فقط برای دارندگان EDIT_PRICE (ادمین) نمایش/ویرایش می‌شود.
- **ویرایش/ثبت قیمت:** EDIT_PRICE + ثبت در PriceHistory و ActivityLog.

## اتصال به درخواست قطعه
فرم ثبت Part Request از این پس آبشاری است: نوع دستگاه → برند → مدل → قطعه (+ کیفیت).
اگر مدل موجود نباشد، کاربر همان‌جا مدل جدید ثبت می‌کند. فیلدهای متنی آزاد قدیمی به‌عنوان
fallback باقی می‌مانند ولی UI جدید همیشه به دسته‌بندی متصل می‌شود.

## انتقال داده (Migration Plan)
پس از تکمیل فیچرها: دیتابیس price-next از سرور فعلی Export و با اسکریپت import به جداول
CRM منتقل می‌شود (DeviceType/Brand/Model/PartCategory/Price → جداول متناظر).
اسکریپت: scripts/import-price-next.ts (در فاز پیاده‌سازی ساخته می‌شود؛ ورودی: dump یا اتصال مستقیم).

## ترتیب پیاده‌سازی
1. Schema: افزودن DeviceType، اتصال DeviceModel به آن، مدل PartPrice، توسعه PriceHistory (modelId/quality)
2. API + UI دسته‌بندی‌ها و اتصال فرم درخواست قطعه به تاکسونومی
3. فیچر Purchasing (ثبت خرید + Auto-Pricing + هشدار اختلاف قیمت + مرجوعی + عدم موجودی)
4. صفحه عمومی /prices + پنل مدیریت قیمت‌ها
5. اسکریپت Import داده از price-next
