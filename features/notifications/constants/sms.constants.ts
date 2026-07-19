import type { PartRequestStatus } from '@prisma/client';

/** کدهای پترن از .env خوانده می‌شوند تا در محیط‌های مختلف قابل تغییر باشند */
export const SMS_PATTERNS = {
  NEW_REQUEST: process.env.SMS_PATTERN_NEW_REQUEST ?? '',
  PRICE_ANNOUNCED: process.env.SMS_PATTERN_PRICE_ANNOUNCED ?? '',
  PURCHASED: process.env.SMS_PATTERN_PURCHASED ?? '',
  NOT_FOUND: process.env.SMS_PATTERN_NOT_FOUND ?? '',
  ADMIN: process.env.SMS_PATTERN_ADMIN ?? '',
} as const;

export type SmsRule = {
  patternCode: string;
  /** گیرنده‌ها بر اساس Permission (نه Role) — docs/06-user-roles.md */
  permissions?: string[];
  /** ثبت‌کننده‌ی درخواست هم بگیرد */
  includeCreator?: boolean;
  /** نام متغیرهای پترن به ترتیب ثبت‌شده در پنل */
  attributes: ('reception' | 'part' | 'model' | 'price' | 'status')[];
};

// نگاشت وضعیت → قانون ارسال (docs/17-notifications.md)
export const STATUS_RULES: Partial<Record<PartRequestStatus, SmsRule>> = {
  WAITING_PURCHASE: {
    patternCode: SMS_PATTERNS.NEW_REQUEST,
    permissions: ['REGISTER_PURCHASE'],
    attributes: ['reception', 'part', 'model'],
  },
  WAITING_CUSTOMER: {
    patternCode: SMS_PATTERNS.PRICE_ANNOUNCED,
    includeCreator: true,
    attributes: ['reception', 'part', 'price'],
  },
  PURCHASED: {
    patternCode: SMS_PATTERNS.PURCHASED,
    includeCreator: true,
    attributes: ['reception', 'part'],
  },
  NOT_FOUND: {
    patternCode: SMS_PATTERNS.NOT_FOUND,
    includeCreator: true,
    permissions: ['CREATE_REPAIR'],
    attributes: ['reception', 'part'],
  },
};

/** سوپر ادمین همه‌ی تغییرات وضعیت را می‌گیرد */
export const ADMIN_RULE: SmsRule = {
  patternCode: SMS_PATTERNS.ADMIN,
  permissions: ['VIEW_ACTIVITY_LOG'],
  attributes: ['reception', 'part', 'status'],
};
