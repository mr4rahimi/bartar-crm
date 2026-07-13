import { z } from 'zod';

export const updateUserSchema = z.object({
  name: z.string().trim().min(2, 'نام باید حداقل ۲ کاراکتر باشد').optional(),
  phone: z.string().regex(/^09\d{9}$/, 'شماره موبایل معتبر نیست').optional(),
  email: z.string().email('ایمیل معتبر نیست').nullable().optional(),
  password: z.string().min(6, 'رمز عبور باید حداقل ۶ کاراکتر باشد').optional(),
  isActive: z.boolean().optional(),
  roleIds: z.array(z.string().min(1)).min(1, 'حداقل یک نقش انتخاب کنید').optional(),
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;
