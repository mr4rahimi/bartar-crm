import { z } from 'zod';
import { customerInputSchema } from './customer.schema';
import { positiveIntField } from '@/shared/validators/number.schema';

export const createTicketSchema = z
  .object({
    customerId: z.string().min(1).optional(),
    newCustomer: customerInputSchema.optional(),

    deviceTypeId: z.string().min(1, 'نوع دستگاه را انتخاب کنید'),
    brandId: z.string().min(1, 'برند را انتخاب کنید'),
    modelId: z.string().min(1, 'مدل را انتخاب کنید'),
    serial: z.string().trim().optional(),
    devicePassword: z.string().trim().optional(),

    estimatedCost: positiveIntField('هزینه تقریبی معتبر نیست').optional(),
    /** ISO date — از تقویم شمسی تبدیل می‌شود */
    estimatedDeliveryAt: z.string().datetime().optional(),

    accessoryIds: z.array(z.string()).default([]),
    issueIds: z.array(z.string()).default([]),

    technicianNotes: z.string().trim().optional(),
    customerNotes: z.string().trim().optional(),
  })
  .refine((data) => Boolean(data.customerId) !== Boolean(data.newCustomer), {
    message: 'مشتری را انتخاب کنید یا ثبت کنید',
    path: ['customerId'],
  });

export type CreateTicketInput = z.infer<typeof createTicketSchema>;
export type CreateTicketFormInput = z.input<typeof createTicketSchema>;
