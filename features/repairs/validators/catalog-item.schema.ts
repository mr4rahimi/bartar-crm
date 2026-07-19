import { z } from 'zod';

export const catalogItemSchema = z.object({
  name: z.string().trim().min(1, 'نام را وارد کنید'),
  deviceTypeId: z.string().min(1).optional(),
});

export type CatalogItemInput = z.infer<typeof catalogItemSchema>;
