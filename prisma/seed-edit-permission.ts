/**
 * افزودن Permission ویرایش درخواست قطعه + تخصیص خودکار به نقش‌های مدیریتی
 * اجرا: npx tsx prisma/seed-edit-permission.ts   (روی سرور هم اجرا شود)
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const permission = await prisma.permission.upsert({
    where: { code: 'EDIT_PART_REQUEST' },
    update: {},
    create: {
      code: 'EDIT_PART_REQUEST',
      group: 'Part Request',
      description: 'ویرایش اطلاعات درخواست قطعه (مدیر)',
    },
  });

  // نقش‌های مدیریتی = نقش‌هایی که ASSIGN_ROLE دارند
  const adminRoles = await prisma.role.findMany({
    where: {
      deletedAt: null,
      permissions: { some: { permission: { code: 'ASSIGN_ROLE' } } },
    },
    select: { id: true, name: true },
  });

  for (const role of adminRoles) {
    await prisma.rolePermission.upsert({
      where: { roleId_permissionId: { roleId: role.id, permissionId: permission.id } },
      update: {},
      create: { roleId: role.id, permissionId: permission.id },
    });
    console.log(`✓ به نقش «${role.name}» اضافه شد`);
  }

  console.log('🎉 Permission ویرایش درخواست آماده است');
}

main()
  .catch((error) => { console.error(error); process.exit(1); })
  .finally(() => prisma.$disconnect());
