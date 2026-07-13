import { prisma } from '@/shared/lib/prisma';

export async function listPermissions() {
  return prisma.permission.findMany({
    orderBy: [{ group: 'asc' }, { code: 'asc' }],
  });
}
