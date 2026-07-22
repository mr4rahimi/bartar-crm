import { prisma } from '@/shared/lib/prisma';

export async function createQualityCheck(data: {
  ticketId: string;
  checkedById: string;
  notes: string;
  passed: boolean;
}) {
  return prisma.qualityCheck.create({ data });
}

export async function listQualityChecks(ticketId: string) {
  return prisma.qualityCheck.findMany({
    where: { ticketId },
    include: { checkedBy: { select: { id: true, name: true } } },
    orderBy: { createdAt: 'desc' },
  });
}
