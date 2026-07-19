import { z } from 'zod';
import { normalizeDigits } from '@/shared/lib/normalize';
import { positiveIntField } from '@/shared/validators/number.schema';

// ویرایش مدیریتی — همه‌ی فیلدها اختیاری‌اند و فقط موارد ارسالی تغییر می‌کنند
export const updatePartRequestSchema = z.object({
  receptionNumber: z.string().trim().min(1).transform(normalizeDigits).optional(),
  partId: z.string().min(1).optional(),
  modelId: z.string().min(1).nullable().optional(),
  quality: z.enum(['ORIGINAL', 'HIGH_COPY', 'COPY']).optional(),
  quantity: positiveIntField('تعداد معتبر نیست').optional(),
  announcedPrice: positiveIntField('قیمت اعلامی معتبر نیست').nullable().optional(),
  depositAmount: positiveIntField('مبلغ بیعانه معتبر نیست').nullable().optional(),
  isTest: z.boolean().optional(),
  description: z.string().trim().nullable().optional(),
});

export type UpdatePartRequestInput = z.infer<typeof updatePartRequestSchema>;
export type UpdatePartRequestFormInput = z.input<typeof updatePartRequestSchema>;
