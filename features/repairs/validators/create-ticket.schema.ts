import { z } from 'zod';

// مشتری: یا انتخاب موجود (customerId) یا ساخت سریع (newCustomer) — دقیقاً یکی
export const createTicketSchema = z
  .object({
    customerId: z.string().min(1).optional(),
    newCustomer: z
      .object({
        name: z.string().trim().min(2, 'نام مشتری باید حداقل ۲ کاراکتر باشد'),
        phone: z.string().regex(/^09\d{9}$/, 'شماره موبایل مشتری معتبر نیست'),
      })
      .optional(),
    brandName: z.string().trim().min(1, 'برند را وارد کنید'),
    modelName: z.string().trim().min(1, 'مدل را وارد کنید'),
    serial: z.string().trim().optional(),
    issueDescription: z.string().trim().optional(),
  })
  .refine((data) => Boolean(data.customerId) !== Boolean(data.newCustomer), {
    message: 'یا مشتری موجود را انتخاب کنید یا مشتری جدید بسازید',
    path: ['customerId'],
  });

export type CreateTicketInput = z.infer<typeof createTicketSchema>;
