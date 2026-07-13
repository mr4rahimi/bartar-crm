import { prisma } from '@/shared/lib/prisma';

const roleInclude = {
  permissions: { include: { permission: true } },
  _count: { select: { users: true } },
} as const;

export async function listRoles() {
  return prisma.role.findMany({
    where: { deletedAt: null },
    include: roleInclude,
    orderBy: { createdAt: 'asc' },
  });
}

export async function findRoleById(roleId: string) {
  return prisma.role.findFirst({
    where: { id: roleId, deletedAt: null },
    include: roleInclude,
  });
}

export async function findRoleByName(name: string) {
  return prisma.role.findFirst({ where: { name, deletedAt: null } });
}

export type CreateRoleData = {
  name: string;
  description: string | null;
  permissionIds: string[];
};

export async function createRole({ permissionIds, ...data }: CreateRoleData) {
  return prisma.role.create({
    data: {
      ...data,
      permissions: { create: permissionIds.map((permissionId) => ({ permissionId })) },
    },
    include: roleInclude,
  });
}

export async function updateRole(
  roleId: string,
  data: { name?: string; description?: string | null },
) {
  return prisma.role.update({ where: { id: roleId }, data });
}

// role_permissions رکورد اتصال است؛ تاریخچه‌ی تغییر در Activity Log ثبت می‌شود
export async function replaceRolePermissions(roleId: string, permissionIds: string[]) {
  return prisma.$transaction([
    prisma.rolePermission.deleteMany({ where: { roleId } }),
    prisma.rolePermission.createMany({
      data: permissionIds.map((permissionId) => ({ roleId, permissionId })),
    }),
  ]);
}

export async function softDeleteRole(roleId: string) {
  return prisma.role.update({ where: { id: roleId }, data: { deletedAt: new Date() } });
}

export async function countRolesByIds(roleIds: string[]) {
  return prisma.role.count({ where: { id: { in: roleIds }, deletedAt: null } });
}
