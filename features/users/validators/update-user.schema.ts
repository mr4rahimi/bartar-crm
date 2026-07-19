import { z } from 'zod';
import { phoneSchema } from '@/shared/validators/phone.schema';

export const updateUserSchema = z.object({
  name: z.string().trim().min(2, 'نام باید حداقل ۲ کاراکتر باشد').optional(),
  phone: phoneSchema.optional(),
  email: z.string().email('ایمیل معتبر نیست').nullable().optional(),
  password: z.string().min(6, 'رمز عبور باید حداقل ۶ کاراکتر باشد').optional(),
  isActive: z.boolean().optional(),
  smsEnabled: z.boolean().optional(),
  roleIds: z.array(z.string().min(1)).min(1, 'حداقل یک نقش انتخاب کنید').optional(),
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;
