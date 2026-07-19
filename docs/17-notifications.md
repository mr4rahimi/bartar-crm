# Notifications — اطلاع‌رسانی پیامکی (IranPayamak)

## سرویس
`POST https://api.iranpayamak.com/ws/v1/sms/pattern` با هدر `Api-Key`.
بدنه: `{ code, recipient, attributes, line_number, number_format }`

## قوانین
- ارسال **غیرمسدودکننده** است: خطای پیامک هرگز ثبت درخواست/خرید را fail نمی‌کند.
- گیرندگان همیشه بر اساس **Permission** تعیین می‌شوند، نه Role (docs/06-user-roles.md).
- هر ارسال در جدول `notifications` با وضعیت SENT/FAILED/SKIPPED ثبت می‌شود.
- کاربر می‌تواند دریافت پیامک را خاموش کند (`users.smsEnabled`).
- اگر کاربری مشمول دو پترن شود، فقط پترن اختصاصی‌تر ارسال می‌شود (جلوگیری از هزینه‌ی تکراری).

## نگاشت رویداد → پترن → گیرنده

| وضعیت نهایی | پترن | گیرنده | متغیرها |
|---|---|---|---|
| WAITING_PURCHASE | NEW_REQUEST | Permission: REGISTER_PURCHASE | reception, part, model |
| WAITING_CUSTOMER | PRICE_ANNOUNCED | ثبت‌کننده‌ی درخواست | reception, part, price |
| PURCHASED | PURCHASED | ثبت‌کننده‌ی درخواست | reception, part |
| NOT_FOUND | NOT_FOUND | ثبت‌کننده + Permission: CREATE_REPAIR | reception, part |
| هر تغییر وضعیت | ADMIN | Permission: VIEW_ACTIVITY_LOG | reception, part, status |

## تنظیمات (.env)


SMS_ENABLED=true|false
IRANPAYAMAK_API_KEY=...
IRANPAYAMAK_LINE_NUMBER=...
IRANPAYAMAK_NUMBER_FORMAT=en|fa
SMS_PATTERN_NEW_REQUEST=...
SMS_PATTERN_PRICE_ANNOUNCED=...
SMS_PATTERN_PURCHASED=...
SMS_PATTERN_NOT_FOUND=...
SMS_PATTERN_ADMIN=...
با `SMS_ENABLED=false` هیچ پیامکی ارسال نمی‌شود و رکورد SKIPPED ثبت می‌گردد.

## تست
npx tsx scripts/test-sms.ts 09120000000

## آینده
پیامک به مشتری (اعلام هزینه و آماده شدن دستگاه) پس از تکمیل فاز پذیرش داخلی.

