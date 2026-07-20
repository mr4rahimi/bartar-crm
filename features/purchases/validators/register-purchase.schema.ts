import { z } from 'zod';
import { phoneSchema } from '@/shared/validators/phone.schema';
import { positiveIntField } from '@/shared/validators/number.schema';
import { normalizeDigits } from '@/shared/lib/normalize';

/** تلفن ثابت با کد شهر — مثلاً 02191300348 */
const landlineSchema = z
  .string()
  .trim()
  .transform((value) => (value ? normalizeDigits(value) : ''))
  .refine((value) => !value || /^0\d{9,10}$/.test(value), 'شماره ثابت معتبر نیست');

export const registerPurchaseSchema = z
  .object({
    partRequestId: z.string().min(1),
    vendorId: z.string().min(1).optional(),
    newVendor: z
      .object({
        name: z.string().trim().min(2, 'نام فروشنده باید حداقل ۲ کاراکتر باشد'),
        phone: phoneSchema.optional(),
        landline: landlineSchema.optional(),
      })
      // حداقل یکی از دو شماره الزامی است (docs/03-business-rules.md)
      .refine((data) => Boolean(data.phone || data.landline), {
        message: 'شماره همراه یا تلفن ثابت را وارد کنید',
        path: ['phone'],
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
export type RegisterPurchaseFormInput = z.input<typeof registerPurchaseSchema>;

export const returnPurchaseSchema = z.object({
  reason: z.string().trim().min(2, 'علت مرجوعی را وارد کنید'),
});

export type ReturnPurchaseInput = z.infer<typeof returnPurchaseSchema>;