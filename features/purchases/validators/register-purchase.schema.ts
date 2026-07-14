import { z } from 'zod';
import { phoneSchema } from '@/shared/validators/phone.schema';
import { positiveIntField } from '@/shared/validators/number.schema';

export const registerPurchaseSchema = z
  .object({
    partRequestId: z.string().min(1),
    vendorId: z.string().min(1).optional(),
    newVendor: z
      .object({
        name: z.string().trim().min(2, 'نام فروشنده باید حداقل ۲ کاراکتر باشد'),
        phone: phoneSchema.optional(),
      })
      .optional(),
    price: positiveIntField('قیمت خرید معتبر نیست'),
    description: z.string().trim().optional(),
  })
  .refine((data) => Boolean(data.vendorId) !== Boolean(data.newVendor), {
    message: 'فروشنده را انتخاب کنید یا فروشنده جدید بسازید',
    path: ['vendorId'],
  });

export type RegisterPurchaseInput = z.infer<typeof registerPurchaseSchema>;

export const returnPurchaseSchema = z.object({
  reason: z.string().trim().min(2, 'علت مرجوعی را وارد کنید'),
});

export type ReturnPurchaseInput = z.infer<typeof returnPurchaseSchema>;
