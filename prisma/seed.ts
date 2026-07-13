import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// این فایل در Feature "Authentication / Users / Roles / Permissions"
// به طور کامل پیاده‌سازی می‌شود.
// فهرست Permissionها و Roleهای پیش‌فرض طبق 06-user-roles.md اینجا Seed خواهند شد.

async function main() {
  console.log('Seed placeholder — پیاده‌سازی کامل در فاز Authentication انجام می‌شود.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
