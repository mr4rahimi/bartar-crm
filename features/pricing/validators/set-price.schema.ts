import { z } from 'zod';
import { positiveIntField } from '@/shared/validators/number.schema';

export const setPriceSchema = z
  .object({
    modelId: z.string().min(1),
    partId: z.string().min(1),
    quality: z.enum(['ORIGINAL', 'HIGH_COPY', 'COPY']),
    buyPrice: positiveIntField('قیمت خرید معتبر نیست').nullable().optional(),
    sellPrice: positiveIntField('قیمت فروش معتبر نیست').nullable().optional(),
    notes: z.string().trim().nullable().optional(),
  })
  .refine((data) => data.buyPrice !== undefined || data.sellPrice !== undefined, {
    message: 'حداقل یکی از قیمت خرید یا فروش را وارد کنید',
    path: ['sellPrice'],
  });

export type SetPriceInput = z.infer<typeof setPriceSchema>;
