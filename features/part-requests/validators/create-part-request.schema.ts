import { z } from 'zod';
import { normalizeDigits } from '@/shared/lib/normalize';
import { positiveIntField } from '@/shared/validators/number.schema';

export const createPartRequestSchema = z.object({
  receptionNumber: z
    .string()
    .trim()
    .min(1, 'شماره پذیرش را وارد کنید')
    .transform(normalizeDigits),
  /** قطعه فقط از کاتالوگ انتخاب می‌شود (جلوگیری از تکرار/غلط املایی) */
  partId: z.string().min(1, 'قطعه را انتخاب کنید'),
  quality: z.enum(['ORIGINAL', 'HIGH_COPY', 'COPY']),
  quantity: positiveIntField('تعداد معتبر نیست').default(1),
  /** اتصال به تاکسونومی قیمت‌گذاری (docs/15) — لازمه‌ی Auto-Pricing */
  modelId: z.string().min(1).optional(),
  repairTicketId: z.string().min(1).optional(),
  brand: z.string().trim().optional(),
  model: z.string().trim().optional(),
  announcedPrice: positiveIntField('قیمت اعلامی معتبر نیست').optional(),
  isTest: z.boolean().default(false),
  description: z.string().trim().optional(),
});

export type CreatePartRequestInput = z.infer<typeof createPartRequestSchema>;
/** تایپ ورودی خام فرم (قبل از transform — رشته هم مجاز است) */
export type CreatePartRequestFormInput = z.input<typeof createPartRequestSchema>;
