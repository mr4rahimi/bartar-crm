import { randomBytes, createHash } from 'crypto';

/** توکن خام — فقط در کوکی مرورگر کاربر ذخیره می‌شود، هرگز در دیتابیس */
export function generateSessionToken(): string {
  return randomBytes(32).toString('hex');
}

/** نسخه‌ی هش‌شده — تنها چیزی که در دیتابیس ذخیره می‌شود */
export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}
