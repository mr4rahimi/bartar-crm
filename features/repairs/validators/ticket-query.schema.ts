import { z } from 'zod';
import { paginationSchema } from '@/shared/validators/pagination.schema';

export const TICKET_SORT_FIELDS = ['createdAt', 'ticketNumber', 'customerName', 'status'] as const;

export const ticketQuerySchema = paginationSchema.extend({
  status: z.enum(['OPEN', 'IN_PROGRESS', 'DELIVERED', 'CLOSED', 'CANCELLED']).optional(),
  sortBy: z.enum(TICKET_SORT_FIELDS).default('createdAt'),
  sortDir: z.enum(['asc', 'desc']).default('desc'),
  /** نمایش سطل حذف‌شده‌ها (نیازمند DELETE_REPAIR) */
  deleted: z
    .union([z.boolean(), z.string()])
    .transform((value) => value === true || value === 'true')
    .default(false),
});

export type TicketQueryInput = z.infer<typeof ticketQuerySchema>;
