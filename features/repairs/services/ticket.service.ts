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
  });

  return { items: items.map(toTicketDto), total, page: query.page, pageSize: query.pageSize };
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
