import { z } from 'zod';

export const loginSchema = z.object({
  phone: z.string().min(10, 'شماره موبایل معتبر نیست'),
  password: z.string().min(6, 'رمز عبور باید حداقل ۶ کاراکتر باشد'),
});

export type LoginInput = z.infer<typeof loginSchema>;
