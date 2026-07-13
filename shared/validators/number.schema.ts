import { z } from 'zod';
import { normalizeDigits } from '@/shared/lib/normalize';

/** عدد صحیح مثبت — رشته با ارقام فارسی/عربی هم پذیرفته می‌شود */
export function positiveIntField(message: string) {
  return z
    .union([z.string(), z.number()])
    .transform((value) => Number(normalizeDigits(String(value).trim())))
    .pipe(z.number({ invalid_type_error: message }).int(message).positive(message));
}
