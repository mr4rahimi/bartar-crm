import { z } from 'zod';
import { phoneSchema } from '@/shared/validators/phone.schema';
import { normalizeDigits } from '@/shared/lib/normalize';

const optionalDigits = z
  .string()
  .trim()
  .transform((value) => (value ? normalizeDigits(value) : ''))
  .optional();

export const customerInputSchema = z
  .object({
    title: z.enum(['MR', 'MRS', 'COMPANY']),
    firstName: z.string().trim().optional(),
    lastName: z.string().trim().optional(),
    companyName: z.string().trim().optional(),
    /** کد ملی (شخص) یا شناسه ملی (شرکت) */
    nationalCode: optionalDigits,
    postalCode: optionalDigits,
    phone: phoneSchema,
    secondaryPhone: phoneSchema.optional(),
    address: z.string().trim().optional(),
  })
  .refine(
    (data) =>
      data.title === 'COMPANY'
        ? Boolean(data.companyName)
        : Boolean(data.firstName && data.lastName),
    { message: 'نام مشتری را کامل وارد کنید', path: ['firstName'] },
  );

export type CustomerInput = z.infer<typeof customerInputSchema>;
export type CustomerFormInput = z.input<typeof customerInputSchema>;
