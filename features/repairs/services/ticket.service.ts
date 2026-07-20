import {
  listTickets,
  findTicketById,
  findTicketByToken,
  createTicketWithRelations,
  nextTicketNumber,
} from '../repositories/ticket.repository';
import { createCustomerService } from './customer.service';
import { findCustomerById } from '../repositories/customer.repository';
import { notifyTicketCreatedAsync } from '@/features/notifications/services/notification.service';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { NotFoundError } from '@/shared/lib/errors';
import { toTicketDto } from '../utils/ticket.mapper';
import type { CreateTicketInput } from '../validators/create-ticket.schema';
import type { TicketQueryInput } from '../validators/ticket-query.schema';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

export async function listTicketsService(query: TicketQueryInput) {
  const { items, total } = await listTickets({
    page: query.page,
    pageSize: query.pageSize,
    search: query.search,
    status: query.status,
    sortBy: query.sortBy,
    sortDir: query.sortDir,
    deleted: query.deleted,
  });

  const dtos = items.map(toTicketDto);

  // نام کاربر حذف‌کننده (بدون Relation در Schema — یک کوئری تجمیعی)
  if (query.deleted) {
    const deleterIds = [...new Set(items.map((item) => item.deletedById).filter(Boolean))] as string[];
    const users = await findUsersByIds(deleterIds);
    const nameById = new Map(users.map((user) => [user.id, user.name]));

    items.forEach((item, index) => {
      const dto = dtos[index];
      if (dto && item.deletedById) dto.deletedByName = nameById.get(item.deletedById) ?? null;
    });
  }

  return { items: dtos, total, page: query.page, pageSize: query.pageSize };
}

export async function getTicketService(ticketId: string) {
  const ticket = await findTicketById(ticketId);
  if (!ticket) throw new NotFoundError('قبض پذیرش یافت نشد');
  return toTicketDto(ticket);
}

/** رسید عمومی مشتری — بدون احراز هویت */
export async function getPublicTicketService(publicToken: string) {
  const ticket = await findTicketByToken(publicToken);
  if (!ticket) throw new NotFoundError('رسید یافت نشد');
  return toTicketDto(ticket);
}

export async function createTicketService(input: CreateTicketInput, context: ActorContext) {
  // ۱) مشتری: موجود یا ثبت جدید
  let customerId: string;
  if (input.customerId) {
    const customer = await findCustomerById(input.customerId);
    if (!customer) throw new NotFoundError('مشتری یافت نشد');
    customerId = customer.id;
  } else {
    const customer = await createCustomerService(input.newCustomer!, context);
    customerId = customer.id;
  }

  // ۲) تیکت با شماره یکتا — یک‌بار Retry برای برخورد همزمانی
  const data = {
    customerId,
    brandId: input.brandId,
    modelId: input.modelId,
    serial: input.serial || null,
    devicePassword: input.devicePassword || null,
    estimatedCost: input.estimatedCost ?? null,
    estimatedDeliveryAt: input.estimatedDeliveryAt ? new Date(input.estimatedDeliveryAt) : null,
    technicianNotes: input.technicianNotes || null,
    customerNotes: input.customerNotes || null,
    createdById: context.actorId,
    accessoryIds: input.accessoryIds,
    issueIds: input.issueIds,
  };

  let ticket;
  try {
    ticket = await createTicketWithRelations({ ...data, ticketNumber: await nextTicketNumber() });
  } catch {
    ticket = await createTicketWithRelations({ ...data, ticketNumber: await nextTicketNumber() });
  }

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_REPAIR',
    entityType: 'RepairTicket',
    entityId: ticket.id,
    newValue: {
      ticketNumber: ticket.ticketNumber,
      customerId,
      device: `${ticket.device.brand.name} ${ticket.device.model.name}`,
      issues: ticket.issues.length,
    },
    ip: context.ip,
    device: context.device,
  });

  // رسید پذیرش برای مشتری — بدون مسدود کردن جریان ثبت
  notifyTicketCreatedAsync({
    ticketId: ticket.id,
    ticketNumber: ticket.ticketNumber,
    customerName: ticket.customer.name,
    customerPhone: ticket.customer.phone,
    deviceTitle: [
      ticket.device.model.deviceType?.name,
      ticket.device.brand.name,
      ticket.device.model.name,
    ]
      .filter(Boolean)
      .join(' '),
    actorId: context.actorId,
  });

  return toTicketDto(ticket);
}

// ----- ویرایش، حذف و بازیابی قبض پذیرش (docs/20-reception-spec.md) -----

import {
  findAnyTicketById,
  updateTicketWithRelations,
  softDeleteTicket,
  restoreTicket,
  findUsersByIds,
} from '../repositories/ticket.repository';
import { AppError } from '@/shared/lib/errors';
import type { UpdateTicketInput } from '../validators/update-ticket.schema';

export async function updateTicketService(
  ticketId: string,
  input: UpdateTicketInput,
  context: ActorContext,
) {
  const current = await findAnyTicketById(ticketId);
  if (!current) throw new NotFoundError('قبض پذیرش یافت نشد');
  if (current.deletedAt) throw new AppError('این قبض حذف شده است', 409);

  const data: Record<string, unknown> = {};
  const device: { brandId?: string; modelId?: string; serial?: string | null } = {};
  const previousValue: Record<string, unknown> = {};
  const newValue: Record<string, unknown> = {};

  const track = (key: string, next: unknown, previous: unknown) => {
    if (next === undefined || next === previous) return false;
    previousValue[key] = previous;
    newValue[key] = next;
    return true;
  };

  if (track('customer', input.customerId, current.customerId)) data.customerId = input.customerId;
  if (track('brand', input.brandId, current.device.brandId)) device.brandId = input.brandId;
  if (track('model', input.modelId, current.device.modelId)) device.modelId = input.modelId;
  if (track('serial', input.serial, current.device.serial)) device.serial = input.serial;
  if (track('devicePassword', input.devicePassword, current.devicePassword)) {
    data.devicePassword = input.devicePassword;
  }
  if (track('shelfNumber', input.shelfNumber, current.shelfNumber)) {
    data.shelfNumber = input.shelfNumber;
  }
  if (track('estimatedCost', input.estimatedCost, current.estimatedCost)) {
    data.estimatedCost = input.estimatedCost;
  }
  if (input.estimatedDeliveryAt !== undefined) {
    const next = input.estimatedDeliveryAt ? new Date(input.estimatedDeliveryAt) : null;
    const previous = current.estimatedDeliveryAt;
    if (next?.getTime() !== previous?.getTime()) {
      previousValue.estimatedDeliveryAt = previous;
      newValue.estimatedDeliveryAt = next;
      data.estimatedDeliveryAt = next;
    }
  }
  if (track('status', input.status, current.status)) data.status = input.status;
  if (track('technicianNotes', input.technicianNotes, current.technicianNotes)) {
    data.technicianNotes = input.technicianNotes;
  }
  if (track('customerNotes', input.customerNotes, current.customerNotes)) {
    data.customerNotes = input.customerNotes;
  }
  if (input.accessoryIds) newValue.accessories = input.accessoryIds.length;
  if (input.issueIds) newValue.issues = input.issueIds.length;

  const ticket = await updateTicketWithRelations({
    ticketId,
    deviceId: current.deviceId,
    data,
    device,
    accessoryIds: input.accessoryIds,
    issueIds: input.issueIds,
  });

  await logActivity({
    userId: context.actorId,
    action: 'EDIT_REPAIR',
    entityType: 'RepairTicket',
    entityId: ticketId,
    previousValue: previousValue as never,
    newValue: newValue as never,
    ip: context.ip,
    device: context.device,
  });

  return toTicketDto(ticket);
}

export async function deleteTicketService(ticketId: string, context: ActorContext) {
  const current = await findAnyTicketById(ticketId);
  if (!current) throw new NotFoundError('قبض پذیرش یافت نشد');
  if (current.deletedAt) throw new AppError('این قبض قبلاً حذف شده است', 409);

  await softDeleteTicket(ticketId, context.actorId);

  await logActivity({
    userId: context.actorId,
    action: 'DELETE_REPAIR',
    entityType: 'RepairTicket',
    entityId: ticketId,
    previousValue: { ticketNumber: current.ticketNumber } as never,
    ip: context.ip,
    device: context.device,
  });
}

export async function restoreTicketService(ticketId: string, context: ActorContext) {
  const current = await findAnyTicketById(ticketId);
  if (!current) throw new NotFoundError('قبض پذیرش یافت نشد');
  if (!current.deletedAt) throw new AppError('این قبض حذف نشده است', 409);

  const ticket = await restoreTicket(ticketId);

  await logActivity({
    userId: context.actorId,
    action: 'RESTORE_REPAIR',
    entityType: 'RepairTicket',
    entityId: ticketId,
    newValue: { ticketNumber: current.ticketNumber } as never,
    ip: context.ip,
    device: context.device,
  });

  return toTicketDto(ticket);
}
