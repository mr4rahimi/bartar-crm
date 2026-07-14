import { z } from 'zod';
import { normalizeDigits } from '@/shared/lib/normalize';
import { positiveIntField } from '@/shared/validators/number.schema';

export const createPartRequestSchema = z.object({
  receptionNumber: z
    .string()
    .trim()
    .min(1, 'شماره پذیرش را وارد کنید')
    .transform(normalizeDigits),
  partName: z.string().trim().min(2, 'نام قطعه باید حداقل ۲ کاراکتر باشد'),
  quality: z.enum(['ORIGINAL', 'HIGH_COPY', 'COPY']),
  quantity: positiveIntField('تعداد معتبر نیست').default(1),
  /** اتصال به تاکسونومی قیمت‌گذاری (docs/15) — لازمه‌ی Auto-Pricing */
  modelId: z.string().min(1).optional(),
  brand: z.string().trim().optional(),
  model: z.string().trim().optional(),
  announcedPrice: positiveIntField('قیمت اعلامی معتبر نیست').optional(),
  isTest: z.boolean().default(false),
  description: z.string().trim().optional(),
});

export type CreatePartRequestInput = z.infer<typeof createPartRequestSchema>;
