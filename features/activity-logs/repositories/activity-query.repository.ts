import { prisma } from '@/shared/lib/prisma';

export async function listEntityLogs(entityType: string, entityId: string) {
  return prisma.activityLog.findMany({
    where: { entityType, entityId },
    include: { user: true },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });
}
