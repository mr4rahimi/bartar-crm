import type { InvoiceWithRelations } from '../repositories/invoice.repository';
import type { InvoiceDto } from '../types/invoice.types';

export function toInvoiceDto(invoice: InvoiceWithRelations): InvoiceDto {
  const { ticket } = invoice;

  return {
    id: invoice.id,
    invoiceNumber: invoice.invoiceNumber,
    ticketId: invoice.ticketId,
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
    items: invoice.items.map((item) => ({
      id: item.id,
      title: item.title,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      total: item.total,
    })),
    subtotal: invoice.subtotal,
    discountType: invoice.discountType,
    discountValue: invoice.discountValue,
    discountAmount: invoice.discountAmount,
    total: invoice.total,
    warrantyMonths: invoice.warrantyMonths,
    hasBatteryNote: invoice.hasBatteryNote,
    extraNotes: invoice.extraNotes,
    createdByName: invoice.createdBy.name,
    createdAt: invoice.createdAt,
  };
}
