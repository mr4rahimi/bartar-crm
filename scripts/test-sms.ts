/**
 * تست ارسال پیامک — بعد از تایید پترن‌ها اجرا کن:
 * npx tsx scripts/test-sms.ts 09120000000
 */
import { sendPatternSms } from '../features/notifications/services/sms-provider.service';
import { SMS_PATTERNS } from '../features/notifications/constants/sms.constants';

async function main() {
  const phone = process.argv[2];
  if (!phone) {
    console.error('شماره موبایل را بده: npx tsx scripts/test-sms.ts 09120000000');
    process.exit(1);
  }

  const result = await sendPatternSms({
    patternCode: SMS_PATTERNS.NEW_REQUEST,
    recipient: phone,
    attributes: { reception: '1042', part: 'باتری', model: 'iPhone 13' },
  });

  console.log(result);
}

main();
