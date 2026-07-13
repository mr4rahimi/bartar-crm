import {
  listTickets,
  findTicketById,
  findLastTicketNumber,
  createTicket,
} from '../repositories/ticket.repository';
import {
  findCustomerById,
  createCustomer,
} from '../repositories/customer.repository';
import {
  listBrandsWithModels,
  upsertBrandAndModel,
  createDevice,
} from '../repositories/catalog.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { NotFoundError } from '@/shared/lib/errors';
import { toTicketDto } from '../utils/ticket.mapper';
import type { CreateTicketInput } from '../validators/create-ticket.schema';
import type { TicketQueryInput } from '../validators/ticket-query.schema';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

const FIRST_TICKET_NUMBER = 1001;

async function nextTicketNumber(): Promise<string> {
  const last = await findLastTicketNumber();
  const lastNumber = last ? parseInt(last, 10) : FIRST_TICKET_NUMBER - 1;
  const base = Number.isNaN(lastNumber) ? FIRST_TICKET_NUMBER - 1 : lastNumber;
  return String(base + 1);
}

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
  if (!ticket) throw new NotFoundError('تیکت تعمیر یافت نشد');
  return toTicketDto(ticket);
}

export async function listCatalogService() {
  const brands = await listBrandsWithModels();
  return brands.map((brand) => ({
    id: brand.id,
    name: brand.name,
    models: brand.models.map((model) => ({ id: model.id, name: model.name })),
  }));
}

export async function createTicketService(input: CreateTicketInput, context: ActorContext) {
  // ۱) مشتری: موجود یا ساخت سریع
  let customerId: string;
  if (input.customerId) {
    const customer = await findCustomerById(input.customerId);
    if (!customer) throw new NotFoundError('مشتری انتخاب‌شده یافت نشد');
    customerId = customer.id;
  } else {
    const customer = await createCustomer(input.newCustomer!);
    customerId = customer.id;
  }

  // ۲) برند/مدل (Upsert) و دستگاه
  const { brand, model } = await upsertBrandAndModel(input.brandName, input.modelName);
  const device = await createDevice({
    brandId: brand.id,
    modelId: model.id,
    serial: input.serial || null,
  });

  // ۳) تیکت با شماره‌ی یکتا — یک‌بار Retry برای برخورد همزمانی
  const data = {
    customerId,
    deviceId: device.id,
    issueDescription: input.issueDescription || null,
    createdById: context.actorId,
  };

  let ticket;
  try {
    ticket = await createTicket({ ...data, ticketNumber: await nextTicketNumber() });
  } catch {
    ticket = await createTicket({ ...data, ticketNumber: await nextTicketNumber() });
  }

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_REPAIR',
    entityType: 'RepairTicket',
    entityId: ticket.id,
    newValue: {
      ticketNumber: ticket.ticketNumber,
      customerId,
      brand: brand.name,
      model: model.name,
    },
    ip: context.ip,
    device: context.device,
  });

  return toTicketDto(ticket);
}
