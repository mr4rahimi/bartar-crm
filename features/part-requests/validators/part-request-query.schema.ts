import { z } from 'zod';
import { paginationSchema } from '@/shared/validators/pagination.schema';

export const partRequestQuerySchema = paginationSchema.extend({
  status: z
    .enum([
      'CREATED', 'WAITING_CUSTOMER', 'APPROVED', 'REJECTED', 'WAITING_PURCHASE',
      'PURCHASING', 'PURCHASED', 'NOT_FOUND', 'DELIVERED', 'RETURNED',
      'CONSUMED', 'CLOSED', 'CANCELLED',
    ])
    .optional(),
});

export type PartRequestQueryInput = z.infer<typeof partRequestQuerySchema>;
