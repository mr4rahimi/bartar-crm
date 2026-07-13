import { z } from 'zod';

export const createUserSchema = z.object({
  name: z.string().trim().min(2, 'نام باید حداقل ۲ کاراکتر باشد'),
  phone: z.string().regex(/^09\d{9}$/, 'شماره موبایل معتبر نیست (مثال: 09123456789)'),
  email: z.string().email('ایمیل معتبر نیست').optional(),
  password: z.string().min(6, 'رمز عبور باید حداقل ۶ کاراکتر باشد'),
  isActive: z.boolean().default(true),
  roleIds: z.array(z.string().min(1)).min(1, 'حداقل یک نقش انتخاب کنید'),
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
