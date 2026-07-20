/**
 * Permissionهای ویرایش و حذف قبض پذیرش
 * اجرا: npx tsx prisma/seed-repair-permissions.ts   (روی سرور هم اجرا شود)
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function grant(permissionCode: string, roleFilterCode: string, description: string) {
  const permission = await prisma.permission.upsert({
    where: { code: permissionCode },
    update: {},
    create: { code: permissionCode, group: 'Repair', description },
  });

  const roles = await prisma.role.findMany({
    where: {
      deletedAt: null,
      permissions: { some: { permission: { code: roleFilterCode } } },
    },
    select: { id: true, name: true },
  });

  for (const role of roles) {
    await prisma.rolePermission.upsert({
      where: { roleId_permissionId: { roleId: role.id, permissionId: permission.id } },
      update: {},
      create: { roleId: role.id, permissionId: permission.id },
    });
    console.log(`✓ ${permissionCode} → «${role.name}»`);
  }
}

async function main() {
  // ویرایش: هر کسی که می‌تواند پذیرش ثبت کند
  await grant('EDIT_REPAIR', 'CREATE_REPAIR', 'ویرایش قبض پذیرش');
  // حذف و مشاهده سطل: فقط نقش‌های مدیریتی
  await grant('DELETE_REPAIR', 'ASSIGN_ROLE', 'حذف قبض پذیرش و مشاهده حذف‌شده‌ها');
  console.log('🎉 Permissionهای پذیرش آماده است');
}

main()
  .catch((error) => { console.error(error); process.exit(1); })
  .finally(() => prisma.$disconnect());
