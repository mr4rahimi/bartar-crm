import { z } from 'zod';

export const createModelSchema = z
  .object({
    name: z.string().trim().min(1, 'نام مدل را وارد کنید'),
    deviceTypeId: z.string().min(1, 'نوع دستگاه را انتخاب کنید'),
    brandId: z.string().min(1).optional(),
    brandName: z.string().trim().min(2, 'نام برند معتبر نیست').optional(),
  })
  .refine((data) => Boolean(data.brandId) || Boolean(data.brandName), {
    message: 'برند را انتخاب یا وارد کنید',
    path: ['brandId'],
  });

export type CreateModelInput = z.infer<typeof createModelSchema>;
