import { prisma } from '@/shared/lib/prisma';
import type { Prisma, RepairTicketStatus } from '@prisma/client';

const ticketInclude = {
  customer: true,
  device: { include: { brand: true, model: true } },
  createdBy: true,
} as const;

export type ListTicketsParams = {
  page: number;
  pageSize: number;
  search?: string;
  status?: RepairTicketStatus;
};

export async function listTickets({ page, pageSize, search, status }: ListTicketsParams) {
  const where: Prisma.RepairTicketWhereInput = {
    deletedAt: null,
    ...(status && { status }),
    ...(search && {
      OR: [
        { ticketNumber: { contains: search } },
        { customer: { name: { contains: search, mode: 'insensitive' } } },
        { customer: { phone: { contains: search } } },
      ],
    }),
  };

  const [items, total] = await prisma.$transaction([
    prisma.repairTicket.findMany({
      where,
      include: ticketInclude,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
    prisma.repairTicket.count({ where }),
  ]);

  return { items, total };
}

export async function findTicketById(ticketId: string) {
  return prisma.repairTicket.findFirst({
    where: { id: ticketId, deletedAt: null },
    include: ticketInclude,
  });
}

export async function findLastTicketNumber(): Promise<string | null> {
  const last = await prisma.repairTicket.findFirst({
    orderBy: { createdAt: 'desc' },
    select: { ticketNumber: true },
  });
  return last?.ticketNumber ?? null;
}

export async function createTicket(data: {
  ticketNumber: string;
  customerId: string;
  deviceId: string;
  issueDescription: string | null;
  createdById: string;
}) {
  return prisma.repairTicket.create({ data, include: ticketInclude });
}
