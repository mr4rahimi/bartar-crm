import type { DiscountType } from '@prisma/client';

export type InvoiceItemDto = {
  id: string;
  title: string;
  quantity: number;
  unitPrice: number;
  total: number;
};

export type InvoiceDto = {
  id: string;
  invoiceNumber: string;
  ticketId: string;
  ticketNumber: string;
  customerName: string;
  customerPhone: string;
  deviceTitle: string;
  items: InvoiceItemDto[];
  subtotal: number;
  discountType: DiscountType | null;
  discountValue: number | null;
  discountAmount: number;
  total: number;
  warrantyMonths: number | null;
  hasBatteryNote: boolean;
  extraNotes: string[];
  createdByName: string;
  createdAt: Date;
};
