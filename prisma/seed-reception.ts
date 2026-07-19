/**
 * Seed متعلقات و ایرادات پذیرش — docs/20-reception-spec.md
 * ایمن برای اجرای مجدد (create-only). روی سرور هم بعد از دیپلوی اجرا شود:
 *   npx tsx prisma/seed-reception.ts
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const normalize = (value: string) => value.replace(/[\s\u200c]/g, '');

const ACCESSORIES: Record<string, string[]> = {
  'موبایل': ['گلس', 'درب پشت', 'رم', 'کابل', 'ال سی دی', 'پیچ', 'سوزن', 'لوازم جانبی ندارد', 'ساعت', 'ندارد', 'قلم', 'باتری', 'سیمکارت', 'قاب', 'کیف', 'خشاب', 'کارتن'],
  'لپ‌تاپ': ['تبدیل کلگی شارژ', 'قلم', 'ندارد', 'قاب', 'هارد', 'کارتن', 'کابل شارژ', 'خشاب', 'کیف', 'باتری', 'شارژر'],
  'تبلت': ['قلم', 'کابل شارژر', 'ندارد', 'قاب', 'سیم کارت', 'رم', 'خشاب', 'کارتن', 'شارژر'],
  'ساعت': ['قاب', 'کیف', 'ادابتور', 'بند ساعت', 'ندارد', 'باتری', 'کارتن', 'شارژر'],
};

const ISSUES: Record<string, string[]> = {
  'موبایل': ['مدار سنسور مجاورت اتصالی دارد', 'قفل FRP', 'درصد شارژ روی صفر مانده است', 'مشکل صدا دارد', 'اتصالی شدید دارد', 'ال سی دی تصویر ندارد', 'پرش آنتن', 'اسپیکر خش خش دارد', 'فلش کار نمیکند', 'صدا قطع میشود', 'روی 1 درصد میماند', 'دکمه پاور ندارد', 'ال سی دی بیرونی تصویر ندارد', 'دوربین سلفی و اصلی کار نمیکند', 'کلید پاور کار نمیکند', 'ال سی دی بیرونی شکسته', 'دوربین اصلی مشکل دارد', 'اینترنت 3G نمیشود', 'خاموش'],
  'لپ‌تاپ': ['در حین کار خاموش میشود', 'رم شناسایی نمیشود', 'ال سی دی تصویر ندارد', 'تاچ اسکرین مشکل دارد', 'ال سی دی مشکل دارد', 'باتری باد کرده', 'دی وی دی رام مشکل دارد', 'USB کار نمیکند', 'سیمکارت شناسایی نمیشود', 'ایردراپ مشکل دارد', 'هات اسپات مشکل دارد', 'تعویض قاب ها', 'کارت صدا مشکل دارد', 'ترمیم قاب ها', 'اس اس دی مشکل دارد', 'ریست پسورد (دیتا ریکاوری)', 'ارتقا دستگاه'],
  'تبلت': ['اتصالی شدید دارد', 'قفل FRP', 'صفحه آبی', 'ال سی دی تصویر ندارد', 'دوربین عقب تار است', 'سیستم شناسایی نمیشود', 'ال سی دی ندارد', 'خاموش میشود ناگهانی', 'شارژ کاذب', 'تغییر رام', 'پرس ال سی دی', 'برنامه نصب نمیشود', 'خشاب سیم کارت تهیه شود', 'تعویض گلس فنی', 'درب پشت شکسته', 'دوربین قطع میشود', 'تاچ کار نمیکند', 'تصویر مشکل دارد'],
};

async function resolveDeviceType(name: string) {
  const all = await prisma.deviceType.findMany();
  const found = all.find((type) => normalize(type.name) === normalize(name));
  if (found) return found;
  return prisma.deviceType.create({ data: { name } });
}

async function main() {
  let accessoryCount = 0;
  let issueCount = 0;

  for (const [typeName, names] of Object.entries(ACCESSORIES)) {
    const deviceType = await resolveDeviceType(typeName);
    for (const name of [...new Set(names)]) {
      const existing = await prisma.accessory.findFirst({
        where: { name, deviceTypeId: deviceType.id },
      });
      if (existing) continue;
      await prisma.accessory.create({ data: { name, deviceTypeId: deviceType.id } });
      accessoryCount++;
    }
  }

  for (const [typeName, names] of Object.entries(ISSUES)) {
    const deviceType = await resolveDeviceType(typeName);
    for (const name of [...new Set(names)]) {
      const existing = await prisma.deviceIssue.findFirst({
        where: { name, deviceTypeId: deviceType.id },
      });
      if (existing) continue;
      await prisma.deviceIssue.create({ data: { name, deviceTypeId: deviceType.id } });
      issueCount++;
    }
  }

  console.log(`✓ ${accessoryCount} متعلقات و ${issueCount} ایراد seed شد`);
}

main()
  .catch((error) => { console.error(error); process.exit(1); })
  .finally(() => prisma.$disconnect());
