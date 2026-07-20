import { z } from 'zod';
import { positiveIntField } from '@/shared/validators/number.schema';

export const invoiceItemSchema = z.object({
  title: z.string().trim().min(1, 'شرح قلم را وارد کنید'),
  quantity: positiveIntField('تعداد معتبر نیست'),
  unitPrice: positiveIntField('قیمت واحد معتبر نیست'),
});

export const invoiceSchema = z.object({
  ticketId: z.string().min(1),
  items: z.array(invoiceItemSchema).min(1, 'حداقل یک قلم به فاکتور اضافه کنید'),
  discountType: z.enum(['PERCENT', 'AMOUNT']).nullable().optional(),
  discountValue: positiveIntField('مقدار تخفیف معتبر نیست').nullable().optional(),
  warrantyMonths: positiveIntField('مدت ضمانت معتبر نیست').nullable().optional(),
  hasBatteryNote: z.boolean().default(false),
  extraNotes: z.array(z.string().trim().min(1)).default([]),
});

export const updateInvoiceSchema = invoiceSchema.omit({ ticketId: true });

export type InvoiceInput = z.infer<typeof invoiceSchema>;
export type InvoiceFormInput = z.input<typeof invoiceSchema>;
export type UpdateInvoiceInput = z.infer<typeof updateInvoiceSchema>;
