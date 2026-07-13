import { z } from 'zod';

export const createRoleSchema = z.object({
  name: z.string().trim().min(2, 'نام نقش باید حداقل ۲ کاراکتر باشد'),
  description: z.string().trim().optional(),
  permissionIds: z.array(z.string().min(1)).min(1, 'حداقل یک دسترسی انتخاب کنید'),
});

export const updateRoleSchema = createRoleSchema.partial();

export type CreateRoleInput = z.infer<typeof createRoleSchema>;
export type UpdateRoleInput = z.infer<typeof updateRoleSchema>;
