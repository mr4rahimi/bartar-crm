import type { RepairTicketStatus } from '@prisma/client';

export const TICKET_STATUS_LABELS: Record<RepairTicketStatus, string> = {
  OPEN: 'پذیرش جدید',
  ASSIGNED: 'ارجاع به تعمیرکار',
  IN_PROGRESS: 'در حال تعمیر',
  QUALITY_CHECK: 'کنترل کیفیت',
  READY_FOR_DELIVERY: 'آماده تحویل',
  UNREPAIRABLE: 'عدم تعمیر',
  DELIVERED_TO_CUSTOMER: 'تحویل به مشتری',
  DELIVERED: 'تحویل شده',
  CLOSED: 'بسته شده',
  CANCELLED: 'لغو شده',
};

export const TICKET_STATUS_CLASSES: Record<RepairTicketStatus, string> = {
  OPEN: 'bg-[#eaf1fe] text-[#1d4ed8] dark:bg-[#122236] dark:text-[#60a5fa]',
  ASSIGNED: 'bg-[#f3ecfd] text-[#7c3aed] dark:bg-[#241633] dark:text-[#c4b5fd]',
  IN_PROGRESS: 'bg-[#fef9e7] text-[#92730c] dark:bg-[#332b0f] dark:text-[#fbbf24]',
  QUALITY_CHECK: 'bg-[#e8f6fb] text-[#0e7490] dark:bg-[#0f2830] dark:text-[#67e8f9]',
  READY_FOR_DELIVERY: 'bg-[#eafaf0] text-[#15803d] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
  UNREPAIRABLE: 'bg-[#fdecec] text-[#b91c1c] dark:bg-[#341313] dark:text-[#f87171]',
  DELIVERED_TO_CUSTOMER: 'bg-foreground/10 text-foreground',
  DELIVERED: 'bg-[#eafaf0] text-[#15803d] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
  CLOSED: 'bg-muted text-muted-foreground',
  CANCELLED: 'bg-[#fdecec] text-[#b91c1c] dark:bg-[#341313] dark:text-[#f87171]',
};

/** ترتیب نمایش در فیلترها — مسیر واقعی کار */
export const TICKET_STATUSES: RepairTicketStatus[] = [
  'OPEN',
  'ASSIGNED',
  'IN_PROGRESS',
  'QUALITY_CHECK',
  'READY_FOR_DELIVERY',
  'UNREPAIRABLE',
  'DELIVERED_TO_CUSTOMER',
  'CANCELLED',
];
