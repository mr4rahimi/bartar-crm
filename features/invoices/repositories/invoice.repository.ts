import { prisma } from '@/shared/lib/prisma';
import type { DiscountType, Prisma } from '@prisma/client';

const invoiceInclude = {
  items: { orderBy: { sortOrder: 'asc' } },
  createdBy: true,
  ticket: {
    include: {
      customer: true,
      device: { include: { brand: true, model: { include: { deviceType: true } } } },
    },
  },
} as const;

export type InvoiceWithRelations = Prisma.InvoiceGetPayload<{ include: typeof invoiceInclude }>;

const INVOICE_NUMBER_START = 1001;

export async function nextInvoiceNumber(): Promise<string> {
  const rows = await prisma.$queryRaw<{ max: number | null }[]>`
    SELECT MAX(CAST("invoiceNumber" AS INTEGER)) AS max
    FROM invoices
    WHERE "invoiceNumber" ~ '^[0-9]+$'
  `;
  const current = rows[0]?.max ?? 0;
  return String(Math.max(current + 1, INVOICE_NUMBER_START));
}

export async function findInvoiceById(invoiceId: string) {
  return prisma.invoice.findFirst({
    where: { id: invoiceId, deletedAt: null },
    include: invoiceInclude,
  });
}

export async function findInvoiceByTicket(ticketId: string) {
  return prisma.invoice.findFirst({
    where: { ticketId, deletedAt: null },
    include: invoiceInclude,
  });
}

export type InvoiceItemData = {
  title: string;
  quantity: number;
  unitPrice: number;
  total: number;
  sortOrder: number;
};

export type InvoiceData = {
  subtotal: number;
  discountType: DiscountType | null;
  discountValue: number | null;
  discountAmount: number;
  total: number;
  warrantyMonths: number | null;
  hasBatteryNote: boolean;
  extraNotes: string[];
};

export async function createInvoice(params: {
  invoiceNumber: string;
  ticketId: string;
  createdById: string;
  data: InvoiceData;
  items: InvoiceItemData[];
}) {
  return prisma.invoice.create({
    data: {
      invoiceNumber: params.invoiceNumber,
      ticketId: params.ticketId,
      createdById: params.createdById,
      ...params.data,
      items: { create: params.items },
    },
    include: invoiceInclude,
  });
}

/** ویرایش: اقلام کاملاً جایگزین می‌شوند */
export async function updateInvoice(params: {
  invoiceId: string;
  data: InvoiceData;
  items: InvoiceItemData[];
}) {
  return prisma.$transaction(async (tx) => {
    await tx.invoiceItem.deleteMany({ where: { invoiceId: params.invoiceId } });
    return tx.invoice.update({
      where: { id: params.invoiceId },
      data: { ...params.data, items: { create: params.items } },
      include: invoiceInclude,
    });
  });
}
