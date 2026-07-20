import {
  nextInvoiceNumber,
  findInvoiceById,
  findInvoiceByTicket,
  createInvoice,
  updateInvoice,
  type InvoiceData,
  type InvoiceItemData,
} from '../repositories/invoice.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { NotFoundError, ConflictError } from '@/shared/lib/errors';
import { toInvoiceDto } from '../utils/invoice.mapper';
import type { InvoiceInput, UpdateInvoiceInput } from '../validators/invoice.schema';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

/** محاسبه‌ی جمع، تخفیف و مبلغ نهایی — همیشه سمت سرور */
function calculate(input: UpdateInvoiceInput): { data: InvoiceData; items: InvoiceItemData[] } {
  const items: InvoiceItemData[] = input.items.map((item, index) => ({
    title: item.title,
    quantity: item.quantity,
    unitPrice: item.unitPrice,
    total: item.quantity * item.unitPrice,
    sortOrder: index,
  }));

  const subtotal = items.reduce((sum, item) => sum + item.total, 0);

  let discountAmount = 0;
  if (input.discountType && input.discountValue) {
    discountAmount =
      input.discountType === 'PERCENT'
        ? Math.floor((subtotal * Math.min(input.discountValue, 100)) / 100)
        : Math.min(input.discountValue, subtotal);
  }

  return {
    items,
    data: {
      subtotal,
      discountType: input.discountType ?? null,
      discountValue: input.discountValue ?? null,
      discountAmount,
      total: subtotal - discountAmount,
      warrantyMonths: input.warrantyMonths ?? null,
      hasBatteryNote: input.hasBatteryNote,
      extraNotes: input.extraNotes,
    },
  };
}

export async function getInvoiceService(invoiceId: string) {
  const invoice = await findInvoiceById(invoiceId);
  if (!invoice) throw new NotFoundError('فاکتور یافت نشد');
  return toInvoiceDto(invoice);
}

/** فاکتور یک قبض پذیرش — اگر وجود نداشته باشد null برمی‌گردد */
export async function getInvoiceByTicketService(ticketId: string) {
  const invoice = await findInvoiceByTicket(ticketId);
  return invoice ? toInvoiceDto(invoice) : null;
}

export async function createInvoiceService(input: InvoiceInput, context: ActorContext) {
  const existing = await findInvoiceByTicket(input.ticketId);
  if (existing) throw new ConflictError('برای این قبض پذیرش قبلاً فاکتور صادر شده است');

  const { data, items } = calculate(input);
  const invoiceNumber = await nextInvoiceNumber();

  const invoice = await createInvoice({
    invoiceNumber,
    ticketId: input.ticketId,
    createdById: context.actorId,
    data,
    items,
  });

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_INVOICE',
    entityType: 'Invoice',
    entityId: invoice.id,
    newValue: { invoiceNumber, total: data.total, items: items.length } as never,
    ip: context.ip,
    device: context.device,
  });

  return toInvoiceDto(invoice);
}

export async function updateInvoiceService(
  invoiceId: string,
  input: UpdateInvoiceInput,
  context: ActorContext,
) {
  const current = await findInvoiceById(invoiceId);
  if (!current) throw new NotFoundError('فاکتور یافت نشد');

  const { data, items } = calculate(input);
  const invoice = await updateInvoice({ invoiceId, data, items });

  await logActivity({
    userId: context.actorId,
    action: 'EDIT_INVOICE',
    entityType: 'Invoice',
    entityId: invoiceId,
    previousValue: { total: current.total, items: current.items.length } as never,
    newValue: { total: data.total, items: items.length } as never,
    ip: context.ip,
    device: context.device,
  });

  return toInvoiceDto(invoice);
}
