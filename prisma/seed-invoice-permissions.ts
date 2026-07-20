/**
 * Permissionهای فاکتور — اجرا: npx tsx prisma/seed-invoice-permissions.ts
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function grant(code: string, sourceCode: string, description: string) {
  const permission = await prisma.permission.upsert({
    where: { code },
    update: {},
    create: { code, group: 'Invoice', description },
  });

  const roles = await prisma.role.findMany({
    where: { deletedAt: null, permissions: { some: { permission: { code: sourceCode } } } },
    select: { id: true, name: true },
  });

  for (const role of roles) {
    await prisma.rolePermission.upsert({
      where: { roleId_permissionId: { roleId: role.id, permissionId: permission.id } },
      update: {},
      create: { roleId: role.id, permissionId: permission.id },
    });
    console.log(`✓ ${code} → «${role.name}»`);
  }
}

async function main() {
  await grant('VIEW_INVOICE', 'VIEW_REPAIR', 'مشاهده فاکتور تعمیر');
  await grant('MANAGE_INVOICE', 'CREATE_REPAIR', 'صدور و ویرایش فاکتور تعمیر');
  console.log('🎉 Permissionهای فاکتور آماده است');
}

main()
  .catch((error) => { console.error(error); process.exit(1); })
  .finally(() => prisma.$disconnect());
