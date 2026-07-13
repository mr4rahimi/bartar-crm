import type { RepairTicketStatus } from '@prisma/client';

export const TICKET_STATUS_LABELS: Record<RepairTicketStatus, string> = {
  OPEN: 'باز',
  IN_PROGRESS: 'در حال تعمیر',
  DELIVERED: 'تحویل شد',
  CLOSED: 'بسته شد',
  CANCELLED: 'لغو شد',
};

export type TicketBadgeVariant = 'blue' | 'green' | 'red' | 'muted';

export const TICKET_STATUS_VARIANTS: Record<RepairTicketStatus, TicketBadgeVariant> = {
  OPEN: 'blue',
  IN_PROGRESS: 'blue',
  DELIVERED: 'green',
  CLOSED: 'muted',
  CANCELLED: 'red',
};
