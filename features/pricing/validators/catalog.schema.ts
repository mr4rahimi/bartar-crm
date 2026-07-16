import { z } from 'zod';

export const nameSchema = z.object({
  name: z.string().trim().min(1, 'نام را وارد کنید'),
});

export const createModelCatalogSchema = z.object({
  name: z.string().trim().min(1, 'نام مدل را وارد کنید'),
  brandId: z.string().min(1, 'برند را انتخاب کنید'),
  deviceTypeId: z.string().min(1, 'نوع دستگاه را انتخاب کنید'),
});

export type NameInput = z.infer<typeof nameSchema>;
export type CreateModelCatalogInput = z.infer<typeof createModelCatalogSchema>;
