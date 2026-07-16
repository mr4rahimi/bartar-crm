import { prisma } from '@/shared/lib/prisma';

export async function listParts() {
  return prisma.part.findMany({
    where: { deletedAt: null },
    orderBy: { name: 'asc' },
  });
}

export async function findPartById(partId: string) {
  return prisma.part.findFirst({ where: { id: partId, deletedAt: null } });
}
