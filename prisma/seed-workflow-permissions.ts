/**
 * Permissionهای جریان تعمیر — اجرا: npx tsx prisma/seed-workflow-permissions.ts
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // ارجاع: پذیرش و مدیران
  const assign = await prisma.permission.upsert({
    where: { code: 'ASSIGN_REPAIR' },
    update: {},
    create: {
      code: 'ASSIGN_REPAIR',
      group: 'Repair',
      description: 'ارجاع دستگاه به تعمیرکار و تغییر تعمیرکار',
    },
  });

  const assignRoles = await prisma.role.findMany({
    where: { deletedAt: null, permissions: { some: { permission: { code: 'CREATE_REPAIR' } } } },
    select: { id: true, name: true },
  });

  for (const role of assignRoles) {
    await prisma.rolePermission.upsert({
      where: { roleId_permissionId: { roleId: role.id, permissionId: assign.id } },
      update: {},
      create: { roleId: role.id, permissionId: assign.id },
    });
    console.log(`✓ ASSIGN_REPAIR → «${role.name}»`);
  }

  // نشانه‌ی تعمیرکار — به هیچ نقشی خودکار داده نمی‌شود
  await prisma.permission.upsert({
    where: { code: 'REPAIR_DEVICE' },
    update: {},
    create: {
      code: 'REPAIR_DEVICE',
      group: 'Repair',
      description: 'تعمیرکار (نمایش در فهرست ارجاع و دریافت دستگاه)',
    },
  });
  console.log('✓ REPAIR_DEVICE ساخته شد — از صفحه نقش‌ها به نقش «تعمیرکار» بدهید');

  console.log('🎉 Permissionهای جریان تعمیر آماده است');
}

main()
  .catch((error) => { console.error(error); process.exit(1); })
  .finally(() => prisma.$disconnect());
