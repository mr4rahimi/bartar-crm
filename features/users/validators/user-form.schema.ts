import { z } from 'zod';
import { createUserSchema } from './create-user.schema';

// فرم ساخت: رمز اجباری | فرم ویرایش: رمز خالی = بدون تغییر
export const createUserFormSchema = createUserSchema.extend({
  email: z.union([z.string().email('ایمیل معتبر نیست'), z.literal('')]),
});

export const editUserFormSchema = createUserFormSchema.extend({
  password: z.union([
    z.string().min(6, 'رمز عبور باید حداقل ۶ کاراکتر باشد'),
    z.literal(''),
  ]),
});

export type UserFormValues = z.infer<typeof editUserFormSchema>;
