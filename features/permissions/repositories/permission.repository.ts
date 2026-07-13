import { prisma } from '@/shared/lib/prisma';

export async function listPermissions() {
  return prisma.permission.findMany({
    orderBy: [{ group: 'asc' }, { code: 'asc' }],
  });
}

export async function countPermissionsByIds(permissionIds: string[]) {
  return prisma.permission.count({ where: { id: { in: permissionIds } } });
}
