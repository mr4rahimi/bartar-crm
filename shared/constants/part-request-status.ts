import type { PartRequestStatus } from '@prisma/client';

export const PART_REQUEST_STATUS_LABELS: Record<PartRequestStatus, string> = {
  CREATED: 'ثبت شده',
  WAITING_CUSTOMER: 'در انتظار تایید مشتری',
  APPROVED: 'تایید شد',
  REJECTED: 'رد شد',
  WAITING_PURCHASE: 'در صف خرید',
  PURCHASING: 'در حال خرید',
  PURCHASED: 'خرید شد',
  NOT_FOUND: 'عدم موجودی',
  DELIVERED: 'تحویل شد',
  RETURNED: 'مرجوع شد',
  CONSUMED: 'مصرف شد',
  CLOSED: 'بسته شد',
  CANCELLED: 'لغو شد',
};

// خانواده‌ی رنگی هر وضعیت — مطابق ماکاپ ui/ و docs/14-ui-design-brief.md
export type StatusFamily = 'gray' | 'yellow' | 'blue' | 'green' | 'red' | 'orange' | 'dark';

export const PART_REQUEST_STATUS_FAMILY: Record<PartRequestStatus, StatusFamily> = {
  CREATED: 'gray',
  WAITING_CUSTOMER: 'yellow',
  WAITING_PURCHASE: 'blue',
  PURCHASING: 'blue',
  APPROVED: 'green',
  PURCHASED: 'green',
  DELIVERED: 'green',
  CONSUMED: 'green',
  REJECTED: 'red',
  CANCELLED: 'red',
  NOT_FOUND: 'red',
  RETURNED: 'orange',
  CLOSED: 'dark',
};
