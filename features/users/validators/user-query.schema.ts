import { z } from 'zod';
import { paginationSchema } from '@/shared/validators/pagination.schema';

export const userQuerySchema = paginationSchema.extend({
  isActive: z.enum(['true', 'false']).optional(),
});

export type UserQueryInput = z.infer<typeof userQuerySchema>;
