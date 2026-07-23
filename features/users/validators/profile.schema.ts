import { z } from 'zod';

export const updateProfileSchema = z.object({
  name: z.string().trim().min(2, 'نام باید حداقل ۲ کاراکتر باشد'),
});

export const changePasswordSchema = z
  .object({
    currentPassword: z.string().min(1, 'رمز فعلی را وارد کنید'),
    newPassword: z.string().min(6, 'رمز جدید باید حداقل ۶ کاراکتر باشد'),
    confirmPassword: z.string().min(1, 'تکرار رمز جدید را وارد کنید'),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    message: 'رمز جدید و تکرار آن یکسان نیستند',
    path: ['confirmPassword'],
  })
  .refine((data) => data.newPassword !== data.currentPassword, {
    message: 'رمز جدید نباید با رمز فعلی یکسان باشد',
    path: ['newPassword'],
  });

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
