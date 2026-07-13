import { z } from 'zod';
import { normalizeDigits } from '@/shared/lib/normalize';

// شماره موبایل: اعداد فارسی/عربی پذیرفته و به لاتین نرمال می‌شوند
export const phoneSchema = z
  .string()
  .transform((value) => normalizeDigits(value.trim()))
  .pipe(z.string().regex(/^09\d{9}$/, 'شماره موبایل معتبر نیست (مثال: 09123456789)'));
