import { notifyRepairEventAsync } from './repair-notify.service';
import { getActorName } from './ticket.service';
import type { Prisma, RepairTicketStatus } from '@prisma/client';
import {
  listTechnicians,
  findTechnicianById,
  applyTransition,
  listStatusHistory,
} from '../repositories/workflow.repository';
import { findAnyTicketById } from '../repositories/ticket.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { NotFoundError, AppError, ForbiddenError } from '@/shared/lib/errors';
import { toTicketDto } from '../utils/ticket.mapper';
import { TICKET_ACTIONS, type TicketAction } from '../constants/workflow.constants';

type ActorContext = {
  actorId: string;
  permissions: string[];
  ip?: string | null;
  device?: string | null;
};

export async function listTechniciansService() {
  return listTechnicians();
}

export async function getTicketHistoryService(ticketId: string) {
  const history = await listStatusHistory(ticketId);
  return history.map((entry) => ({
    id: entry.id,
    previousStatus: entry.previousStatus,
    newStatus: entry.newStatus,
    action: entry.action,
    changedByName: entry.changedBy.name,
    description: entry.description,
    createdAt: entry.createdAt,
  }));
}

/** اقدام‌های مجاز برای این کاربر روی این تیکت (برای رابط کاربری) */
export function availableActionsFor(
  status: RepairTicketStatus,
  assignedToId: string | null,
  actorId: string,
  permissions: string[],
) {
  return TICKET_ACTIONS.filter((def) => {
    if (!def.from.includes(status)) return false;
    const isAssignee = assignedToId === actorId;
    const hasPermission = def.permission ? permissions.includes(def.permission) : false;

    if (def.assigneeOnly && def.permission) return isAssignee || hasPermission;
    if (def.assigneeOnly) return isAssignee;
    if (def.permission) return hasPermission;
    return true;
  }).map((def) => ({
    action: def.action,
    label: def.label,
    requiresTechnician: Boolean(def.requiresTechnician),
    requiresReason: Boolean(def.requiresReason),
    tone: def.tone,
  }));
}

export type ApplyTicketActionInput = {
  action: TicketAction;
  technicianId?: string;
  reason?: string;
};

export async function applyTicketActionService(
  ticketId: string,
  input: ApplyTicketActionInput,
  context: ActorContext,
) {
  const ticket = await findAnyTicketById(ticketId);
  if (!ticket) throw new NotFoundError('قبض پذیرش یافت نشد');
  if (ticket.deletedAt) throw new AppError('این قبض حذف شده است', 409);

  const def = TICKET_ACTIONS.find((item) => item.action === input.action);
  if (!def) throw new AppError('اقدام نامعتبر است', 400);

  // گذار مجاز از وضعیت فعلی؟
  if (!def.from.includes(ticket.status)) {
    throw new AppError('این اقدام در وضعیت فعلی مجاز نیست', 409);
  }

  // مجوز: تعمیرکارِ همین تیکت یا Permission
  const isAssignee = ticket.assignedToId === context.actorId;
  const hasPermission = def.permission ? context.permissions.includes(def.permission) : false;
  const allowed = def.assigneeOnly
    ? isAssignee || (def.permission ? hasPermission : false)
    : def.permission
      ? hasPermission
      : true;
  if (!allowed) throw new ForbiddenError('شما مجاز به این اقدام نیستید');

  if (def.requiresReason && !input.reason?.trim()) {
    throw new AppError('ذکر علت الزامی است', 400);
  }

  // ساخت داده‌ی به‌روزرسانی بر اساس نوع اقدام
  const ticketData: Prisma.RepairTicketUpdateInput = { status: def.to };
  let assignedToId: string | null = ticket.assignedToId;
  let assignedToName: string | null = null;

  if (def.requiresTechnician) {
    const technician = input.technicianId
      ? await findTechnicianById(input.technicianId)
      : null;
    if (!technician) throw new AppError('تعمیرکار انتخاب‌شده معتبر نیست', 400);

    assignedToId = technician.id;
    assignedToName = technician.name;
    ticketData.assignedTo = { connect: { id: technician.id } };
    ticketData.assignedById = context.actorId;
    ticketData.assignedAt = new Date();
    ticketData.acceptedAt = null; // ارجاع جدید → تحویل‌نگرفته
  }

  if (input.action === 'ACCEPT') {
    ticketData.acceptedAt = new Date();
  }

  if (input.action === 'RETURN_TO_RECEPTION') {
    assignedToId = null;
    ticketData.assignedTo = { disconnect: true };
    ticketData.assignedAt = null;
    ticketData.acceptedAt = null;
  }

  const updated = await applyTransition({
    ticketId,
    previousStatus: ticket.status,
    newStatus: def.to,
    action: def.action,
    changedById: context.actorId,
    assignedToId,
    description: input.reason?.trim() || null,
    ticketData,
  });

  await logActivity({
    userId: context.actorId,
    action: `TICKET_${def.action}`,
    entityType: 'RepairTicket',
    entityId: ticketId,
    previousValue: { status: ticket.status } as never,
    newValue: {
      status: def.to,
      ...(assignedToName && { assignedTo: assignedToName }),
      ...(input.reason?.trim() && { reason: input.reason.trim() }),
    } as never,
    ip: context.ip,
    device: context.device,
  });

  notifyRepairEventAsync({
    action: def.action,
    ticketId,
    ticketNumber: ticket.ticketNumber,
    deviceTitle: [
      updated.device.model.deviceType?.name,
      updated.device.brand.name,
      updated.device.model.name,
    ]
      .filter(Boolean)
      .join(' '),
    assignedToId,
    assignedToName,
    assignedToPhone: assignedToName ? (await findTechnicianById(assignedToId!))?.phone ?? null : null,
    actorId: context.actorId,
    actorName: await getActorName(context.actorId),
    assignedById: ticket.assignedById,
    reason: input.reason?.trim() || null,
  });

  return { ticket: toTicketDto(updated), assignedToId, assignedToName, action: def.action };
}
