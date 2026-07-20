import type { RepairTicketStatus } from '@prisma/client';

export const TICKET_STATUS_LABELS: Record<RepairTicketStatus, string> = {
  OPEN: 'پذیرش جدید',
  IN_PROGRESS: 'در حال تعمیر',
  DELIVERED: 'تحویل شده',
  CLOSED: 'بسته شده',
  CANCELLED: 'لغو شده',
};

export const TICKET_STATUS_CLASSES: Record<RepairTicketStatus, string> = {
  OPEN: 'bg-[#eaf1fe] text-[#1d4ed8] dark:bg-[#122236] dark:text-[#60a5fa]',
  IN_PROGRESS: 'bg-[#fef9e7] text-[#92730c] dark:bg-[#332b0f] dark:text-[#fbbf24]',
  DELIVERED: 'bg-[#eafaf0] text-[#15803d] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
  CLOSED: 'bg-muted text-muted-foreground',
  CANCELLED: 'bg-[#fdecec] text-[#b91c1c] dark:bg-[#341313] dark:text-[#f87171]',
};

export const TICKET_STATUSES: RepairTicketStatus[] = [
  'OPEN',
  'IN_PROGRESS',
  'DELIVERED',
  'CLOSED',
  'CANCELLED',
];
