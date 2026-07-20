import type { RepairTicketStatus } from '@prisma/client';

export type TicketAction =
  | 'ASSIGN'
  | 'REASSIGN'
  | 'ACCEPT'
  | 'RETURN_TO_RECEPTION'
  | 'HANDOFF';

export type TicketActionDef = {
  action: TicketAction;
  label: string;
  from: RepairTicketStatus[];
  to: RepairTicketStatus;
  /** Permission لازم (به‌جای تعمیرکارِ همین تیکت) */
  permission?: string;
  /** فقط تعمیرکارِ فعلیِ همین تیکت مجاز است */
  assigneeOnly?: boolean;
  /** نیازمند انتخاب تعمیرکار مقصد */
  requiresTechnician?: boolean;
  /** توضیح/علت اجباری */
  requiresReason?: boolean;
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
];

export const TICKET_ACTION_LABELS: Record<string, string> = Object.fromEntries(
  TICKET_ACTIONS.map((def) => [def.action, def.label]),
);
