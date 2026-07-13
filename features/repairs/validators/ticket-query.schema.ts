import { z } from 'zod';
import { paginationSchema } from '@/shared/validators/pagination.schema';

export const ticketQuerySchema = paginationSchema.extend({
  status: z.enum(['OPEN', 'IN_PROGRESS', 'DELIVERED', 'CLOSED', 'CANCELLED']).optional(),
});

export type TicketQueryInput = z.infer<typeof ticketQuerySchema>;
