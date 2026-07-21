import type { PartRequestStatus } from '@prisma/client';

export const PART_REQUEST_ACTIONS = [
  'ANNOUNCE_PRICE',
  'APPROVE',
  'REJECT',
  'CANCEL',
  'START_PURCHASE',
  'MARK_NOT_FOUND',
  'BACK_TO_QUEUE',
  'DELIVER',
  'CONSUME',
  'CLOSE',
] as const;

export type PartRequestAction = (typeof PART_REQUEST_ACTIONS)[number];

export type ActionDef = {
  action: PartRequestAction;
  label: string;
  /** وضعیت‌های مبدا مجاز — docs/05-workflows.md Allowed Transitions */
  from: PartRequestStatus[];
  to: PartRequestStatus;
  /** کد Permission لازم (بررسی در Route) */
  permission: string;
  requiresPrice?: boolean;
  /** عملیات مهم که طبق 09-ui-guidelines.md نیاز به تایید دارند */
  requiresConfirm?: boolean;
  /** فقط تعمیرکار درخواست‌دهنده (createdById) یا دارندگان permission — docs/22 */
  requesterOnly?: boolean;
  /** رنگ دکمه در UI */
  tone: 'primary' | 'outline' | 'destructive';
};

// نکته‌ها:
// - APPROVE طبق Workflow 3 بعد از APPROVED خودکار وارد WAITING_PURCHASE می‌شود (در Service)
// - BACK_TO_QUEUE طبق Business Rule «NOT_FOUND قابل بازگشت است»
// - گذار PURCHASING → PURCHASED فقط از طریق ثبت خرید (فیچر purchases) انجام می‌شود
export const ACTION_DEFS: ActionDef[] = [
  { action: 'ANNOUNCE_PRICE', label: 'اعلام هزینه', from: ['CREATED'], to: 'WAITING_CUSTOMER', permission: 'CHANGE_STATUS', requiresPrice: true, tone: 'primary' },
  { action: 'APPROVE', label: 'تایید مشتری', from: ['WAITING_CUSTOMER'], to: 'APPROVED', permission: 'CHANGE_STATUS', tone: 'primary' },
  { action: 'REJECT', label: 'رد مشتری', from: ['WAITING_CUSTOMER'], to: 'REJECTED', permission: 'CHANGE_STATUS', requiresConfirm: true, tone: 'destructive' },
  { action: 'CANCEL', label: 'لغو درخواست', from: ['CREATED', 'WAITING_CUSTOMER', 'APPROVED', 'WAITING_PURCHASE'], to: 'CANCELLED', permission: 'CHANGE_STATUS', requiresConfirm: true, tone: 'destructive' },
  { action: 'START_PURCHASE', label: 'شروع خرید', from: ['WAITING_PURCHASE'], to: 'PURCHASING', permission: 'START_PURCHASE', tone: 'primary' },
  { action: 'MARK_NOT_FOUND', label: 'عدم موجودی', from: ['WAITING_PURCHASE', 'PURCHASING'], to: 'NOT_FOUND', permission: 'NOT_FOUND', requiresConfirm: true, tone: 'destructive' },
  { action: 'BACK_TO_QUEUE', label: 'بازگشت به صف خرید', from: ['NOT_FOUND', 'RETURNED'], to: 'WAITING_PURCHASE', permission: 'CHANGE_STATUS', tone: 'outline' },
 { action: 'DELIVER', label: 'تحویل به تعمیرکار', from: ['PURCHASED'], to: 'DELIVERED', permission: 'CHANGE_STATUS', requesterOnly: true, tone: 'primary' },
  { action: 'CONSUME', label: 'مصرف / نصب شد', from: ['DELIVERED'], to: 'CONSUMED', permission: 'CHANGE_STATUS', tone: 'primary' },
  { action: 'CLOSE', label: 'بستن درخواست', from: ['CONSUMED'], to: 'CLOSED', permission: 'CHANGE_STATUS', tone: 'outline' },
];

export function findActionDef(action: PartRequestAction): ActionDef {
  return ACTION_DEFS.find((def) => def.action === action)!;
}

export const QUALITY_LABELS = {
  ORIGINAL: 'اورجینال',
  HIGH_COPY: 'های‌کپی',
  COPY: 'کپی',
} as const;
