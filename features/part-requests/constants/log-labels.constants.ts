import type { PartQuality, PartRequestStatus } from '@prisma/client';
import { PART_REQUEST_STATUS_LABELS } from '@/shared/constants/part-request-status';
import { QUALITY_LABELS } from './state-machine.constants';

export const LOG_ACTION_LABELS: Record<string, string> = {
  CREATE_PART_REQUEST: 'ثبت درخواست',
  CHANGE_STATUS: 'تغییر وضعیت',
  EDIT_PART_REQUEST: 'ویرایش اطلاعات',
  REGISTER_PURCHASE: 'ثبت خرید',
  RETURN_PURCHASE: 'ثبت مرجوعی',
};

export const LOG_FIELD_LABELS: Record<string, string> = {
  receptionNumber: 'شماره پذیرش',
  part: 'قطعه',
  model: 'مدل',
  quality: 'کیفیت',
  quantity: 'تعداد',
  announcedPrice: 'قیمت اعلامی',
  depositAmount: 'بیعانه',
  isTest: 'درخواست تستی',
  description: 'توضیح',
  status: 'وضعیت',
  action: 'اقدام',
  price: 'مبلغ',
};

/** نمایش خوانا برای مقدار هر فیلد در تاریخچه */
export function formatLogValue(field: string, value: unknown): string {
  if (value === null || value === undefined || value === '') return '—';
  if (typeof value === 'boolean') return value ? 'بله' : 'خیر';
  if (field === 'quality') return QUALITY_LABELS[value as PartQuality] ?? String(value);
  if (field === 'status') return PART_REQUEST_STATUS_LABELS[value as PartRequestStatus] ?? String(value);
  if (typeof value === 'number') return value.toLocaleString('fa-IR');
  return String(value);
}
