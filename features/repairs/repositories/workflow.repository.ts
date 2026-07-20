import { prisma } from '@/shared/lib/prisma';
import type { Prisma, RepairTicketStatus } from '@prisma/client';

/** تعمیرکاران = کاربران فعال دارای REPAIR_DEVICE */
export async function listTechnicians() {
  return prisma.user.findMany({
    where: {
      deletedAt: null,
      isActive: true,
      roles: {
        some: { role: { deletedAt: null, permissions: { some: { permission: { code: 'REPAIR_DEVICE' } } } } },
      },
    },
    select: { id: true, name: true, phone: true },
    orderBy: { name: 'asc' },
  });
}

export async function findTechnicianById(userId: string) {
  return prisma.user.findFirst({
    where: {
      id: userId,
      deletedAt: null,
      isActive: true,
      roles: {
        some: { role: { deletedAt: null, permissions: { some: { permission: { code: 'REPAIR_DEVICE' } } } } },
      },
    },
    select: { id: true, name: true, phone: true },
  });
}

/** اجرای گذار وضعیت + ثبت تاریخچه در یک تراکنش */
export async function applyTransition(params: {
  ticketId: string;
  previousStatus: RepairTicketStatus;
  newStatus: RepairTicketStatus;
  action: string;
  changedById: string;
  assignedToId?: string | null;
  description?: string | null;
  ticketData: Prisma.RepairTicketUpdateInput;
}) {
  return prisma.$transaction(async (tx) => {
    const ticket = await tx.repairTicket.update({
      where: { id: params.ticketId },
      data: params.ticketData,
      include: {
        customer: true,
        createdBy: true,
        assignedTo: true,
        device: { include: { brand: true, model: { include: { deviceType: true } } } },
        accessories: { include: { accessory: true } },
        issues: { include: { issue: true } },
      },
    });

    await tx.ticketStatusHistory.create({
      data: {
        ticketId: params.ticketId,
        previousStatus: params.previousStatus,
        newStatus: params.newStatus,
        action: params.action,
        changedById: params.changedById,
        assignedToId: params.assignedToId ?? null,
        description: params.description ?? null,
      },
    });

    return ticket;
  });
}

export async function listStatusHistory(ticketId: string) {
  return prisma.ticketStatusHistory.findMany({
    where: { ticketId },
    include: { changedBy: true },
    orderBy: { createdAt: 'desc' },
  });
}
