import type { RepairTicketStatus } from '@prisma/client';

export type TicketAction =
  | 'ASSIGN'
  | 'REASSIGN'
  | 'ACCEPT'
  | 'RETURN_TO_RECEPTION'
  | 'HANDOFF'
  | 'MARK_REPAIRED'
  | 'PASS_QUALITY'
  | 'FAIL_QUALITY'
  | 'MARK_UNREPAIRABLE'
  | 'RECEIVE_BY_RECEPTION'
  | 'DELIVER_TO_CUSTOMER';

export type TicketActionDef = {
  action: TicketAction;
  label: string;
  from: RepairTicketStatus[];
  to?: RepairTicketStatus;
  /** Permission لازم (به‌جای تعمیرکارِ همین تیکت) */
  permission?: string;
  /** فقط تعمیرکار/نگهدارنده‌ی فعلی مجاز است */
  assigneeOnly?: boolean;
  /** نیازمند انتخاب تعمیرکار مقصد */
  requiresTechnician?: boolean;
  /** انتخاب تعمیرکار اختیاری است (خالی = خودم) */
  technicianOptional?: boolean;
  /** توضیح/علت اجباری */
  requiresReason?: boolean;
  /** موارد کنترل‌شده اجباری (کنترل کیفیت) */
  requiresQualityNotes?: boolean;
  /** پرسش ارسال پیامک آماده‌بودن به مشتری */
  asksCustomerSms?: boolean;
  /** پرسش چاپ قبض تحویل */
  asksPrintReceipt?: boolean;
  tone: 'primary' | 'default' | 'destructive';
};

// ماشین وضعیت داده‌محور — docs/22-repair-workflow.md
export const TICKET_ACTIONS: TicketActionDef[] = [
  {
    action: 'ASSIGN',
    label: 'ارجاع به تعمیرکار',
    from: ['OPEN'],
    to: 'ASSIGNED',
    permission: 'ASSIGN_REPAIR',
    requiresTechnician: true,
    tone: 'primary',
  },
  {
    action: 'ACCEPT',
    label: 'تحویل گرفتم',
    from: ['ASSIGNED'],
    to: 'IN_PROGRESS',
    assigneeOnly: true,
    tone: 'primary',
  },
  {
    action: 'REASSIGN',
    label: 'تغییر تعمیرکار',
    from: ['ASSIGNED'],
    to: 'ASSIGNED',
    permission: 'ASSIGN_REPAIR',
    requiresTechnician: true,
    tone: 'default',
  },
  {
    action: 'HANDOFF',
    label: 'ارجاع به تعمیرکار دیگر',
    from: ['IN_PROGRESS'],
    to: 'ASSIGNED',
    assigneeOnly: true,
    permission: 'ASSIGN_REPAIR',
    requiresTechnician: true,
    requiresReason: true,
    tone: 'default',
  },
  {
    action: 'RETURN_TO_RECEPTION',
    label: 'بازگشت به پذیرش',
    from: ['ASSIGNED'],
    to: 'OPEN',
    assigneeOnly: true,
    permission: 'ASSIGN_REPAIR',
    requiresReason: true,
    tone: 'destructive',
  },
  // ----- تکمیل تعمیر -----
  {
    action: 'MARK_REPAIRED',
    label: 'تعمیر شد',
    from: ['IN_PROGRESS'],
    to: 'QUALITY_CHECK',
    assigneeOnly: true,
    requiresTechnician: true,
    technicianOptional: true, // خالی = کنترل کیفیت توسط خودم
    tone: 'primary',
  },
  {
    action: 'PASS_QUALITY',
    label: 'تایید کنترل کیفیت',
    from: ['QUALITY_CHECK'],
    to: 'READY_FOR_DELIVERY',
    assigneeOnly: true,
    requiresQualityNotes: true,
    tone: 'primary',
  },
  {
    action: 'FAIL_QUALITY',
    label: 'رد کنترل کیفیت',
    from: ['QUALITY_CHECK'],
    to: 'IN_PROGRESS',
    assigneeOnly: true,
    requiresReason: true,
    tone: 'destructive',
  },
  {
    action: 'MARK_UNREPAIRABLE',
    label: 'عدم تعمیر',
    from: ['IN_PROGRESS'],
    to: 'UNREPAIRABLE',
    assigneeOnly: true,
    requiresReason: true,
    tone: 'destructive',
  },
  // ----- پذیرش و تحویل -----
  {
    action: 'RECEIVE_BY_RECEPTION',
    label: 'تحویل گرفتم از تعمیرکار',
    from: ['READY_FOR_DELIVERY', 'UNREPAIRABLE'],
    // وضعیت تغییر نمی‌کند؛ فقط ثبت تحویل به پذیرش
    permission: 'ASSIGN_REPAIR',
    asksCustomerSms: true,
    tone: 'primary',
  },
  {
    action: 'DELIVER_TO_CUSTOMER',
    label: 'تحویل به مشتری',
    from: ['READY_FOR_DELIVERY', 'UNREPAIRABLE'],
    to: 'DELIVERED_TO_CUSTOMER',
    permission: 'ASSIGN_REPAIR',
    asksPrintReceipt: true,
    tone: 'primary',
  },
];

export const TICKET_ACTION_LABELS: Record<string, string> = Object.fromEntries(
  TICKET_ACTIONS.map((def) => [def.action, def.label]),
);
