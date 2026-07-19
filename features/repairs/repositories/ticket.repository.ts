import { prisma } from '@/shared/lib/prisma';
import type { Prisma, RepairTicketStatus } from '@prisma/client';

const ticketInclude = {
  customer: true,
  createdBy: true,
  device: { include: { brand: true, model: { include: { deviceType: true } } } },
  accessories: { include: { accessory: true } },
  issues: { include: { issue: true } },
} as const;

export type TicketWithRelations = Prisma.RepairTicketGetPayload<{
  include: typeof ticketInclude;
}>;

/** شماره پذیرش از ۲۰۰۰۱ شروع می‌شود (docs/20-reception-spec.md) */
const TICKET_NUMBER_START = 20001;

export async function nextTicketNumber(): Promise<string> {
  const rows = await prisma.$queryRaw<{ max: number | null }[]>`
    SELECT MAX(CAST("ticketNumber" AS INTEGER)) AS max
    FROM repair_tickets
    WHERE "ticketNumber" ~ '^[0-9]+$'
  `;
  const current = rows[0]?.max ?? 0;
  return String(Math.max(current + 1, TICKET_NUMBER_START));
}

export async function listTickets(params: {
  page: number;
  pageSize: number;
  search?: string;
  status?: RepairTicketStatus;
}) {
  const where: Prisma.RepairTicketWhereInput = {
    deletedAt: null,
    ...(params.status && { status: params.status }),
    ...(params.search && {
      OR: [
        { ticketNumber: { contains: params.search } },
        { customer: { name: { contains: params.search, mode: 'insensitive' } } },
        { customer: { phone: { contains: params.search } } },
      ],
    }),
  };

  const [items, total] = await prisma.$transaction([
    prisma.repairTicket.findMany({
      where,
      include: ticketInclude,
      orderBy: { createdAt: 'desc' },
      skip: (params.page - 1) * params.pageSize,
      take: params.pageSize,
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

export async function findTicketByToken(publicToken: string) {
  return prisma.repairTicket.findFirst({
    where: { publicToken, deletedAt: null },
    include: ticketInclude,
  });
}

export type CreateTicketData = {
  ticketNumber: string;
  customerId: string;
  brandId: string;
  modelId: string;
  serial: string | null;
  devicePassword: string | null;
  estimatedCost: number | null;
  estimatedDeliveryAt: Date | null;
  technicianNotes: string | null;
  customerNotes: string | null;
  createdById: string;
  accessoryIds: string[];
  issueIds: string[];
};

/** ساخت دستگاه + تیکت + اتصال ایرادات و متعلقات در یک تراکنش */
export async function createTicketWithRelations(data: CreateTicketData) {
  return prisma.$transaction(async (tx) => {
    const device = await tx.device.create({
      data: { brandId: data.brandId, modelId: data.modelId, serial: data.serial },
    });

    const ticket = await tx.repairTicket.create({
      data: {
        ticketNumber: data.ticketNumber,
        customerId: data.customerId,
        deviceId: device.id,
        devicePassword: data.devicePassword,
        estimatedCost: data.estimatedCost,
        estimatedDeliveryAt: data.estimatedDeliveryAt,
        technicianNotes: data.technicianNotes,
        customerNotes: data.customerNotes,
        createdById: data.createdById,
        accessories: {
          create: data.accessoryIds.map((accessoryId) => ({ accessoryId })),
        },
        issues: {
          create: data.issueIds.map((issueId) => ({ issueId })),
        },
      },
      include: ticketInclude,
    });

    return ticket;
  });
}
