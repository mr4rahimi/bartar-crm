import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { PERMISSIONS } from '../features/permissions/constants/permission-codes.constants';
import { DEFAULT_ROLES } from '../features/permissions/constants/default-roles.constants';

const prisma = new PrismaClient();

async function seedPermissions() {
  for (const permission of Object.values(PERMISSIONS)) {
    await prisma.permission.upsert({
      where: { code: permission.code },
      update: { group: permission.group },
      create: { code: permission.code, group: permission.group },
    });
  }
  console.log(`✓ ${Object.values(PERMISSIONS).length} Permission seed شد`);
}

async function seedRoles() {
  for (const [roleName, roleDef] of Object.entries(DEFAULT_ROLES)) {
    const role = await prisma.role.upsert({
      where: { name: roleName },
      update: { description: roleDef.description },
      create: { name: roleName, description: roleDef.description },
    });

    for (const permissionCode of roleDef.permissions) {
      const permission = await prisma.permission.findUniqueOrThrow({
        where: { code: permissionCode },
      });

      await prisma.rolePermission.upsert({
        where: { roleId_permissionId: { roleId: role.id, permissionId: permission.id } },
        update: {},
        create: { roleId: role.id, permissionId: permission.id },
      });
    }
  }
  console.log(`✓ ${Object.keys(DEFAULT_ROLES).length} Role seed شد`);
}

async function seedBootstrapAdmin() {
  const phone = process.env.BOOTSTRAP_ADMIN_PHONE;
  const password = process.env.BOOTSTRAP_ADMIN_PASSWORD;
  const name = process.env.BOOTSTRAP_ADMIN_NAME ?? 'مدیر سیستم';

  if (!phone || !password) {
    console.warn('⚠ BOOTSTRAP_ADMIN_PHONE / BOOTSTRAP_ADMIN_PASSWORD در .env تنظیم نشده — ادمین اولیه ساخته نشد.');
    return;
  }

  const existing = await prisma.user.findFirst({ where: { phone } });
  if (existing) {
    console.log('✓ ادمین اولیه از قبل وجود دارد، رد شد');
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);

  const admin = await prisma.user.create({
    data: { name, phone, passwordHash, isActive: true },
  });

  const superAdminRole = await prisma.role.findUniqueOrThrow({
    where: { name: 'Super Admin' },
  });

  await prisma.userRole.create({
    data: { userId: admin.id, roleId: superAdminRole.id },
  });

  console.log(`✓ ادمین اولیه ساخته شد — phone: ${phone}`);
}

async function main() {
  await seedPermissions();
  await seedRoles();
  await seedBootstrapAdmin();
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
