import { prisma } from '@/shared/lib/prisma';

export async function createRepairNote(data: {
  ticketId: string;
  authorId: string;
  body: string;
}) {
  return prisma.repairNote.create({
    data,
    include: { author: { select: { id: true, name: true } } },
  });
}

export async function listRepairNotes(ticketId: string) {
  return prisma.repairNote.findMany({
    where: { ticketId },
    include: { author: { select: { id: true, name: true } } },
    orderBy: { createdAt: 'desc' },
  });
}
